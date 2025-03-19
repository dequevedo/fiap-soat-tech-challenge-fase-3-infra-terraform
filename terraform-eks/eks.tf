module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true
  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = { most_recent = true }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]

    node_security_group_tags = {
      "kubernetes.io/cluster/${local.name}" = null
    }
  }

  eks_managed_node_groups = {
    amc-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

  tags = local.tags
}

### IAM Access Entries
variable "eks_users" {
  default = ["tech-challenge-terraform-user", "tech-challenge-github-actions-user"]
}

# Obtém a conta AWS atual para usar no ARN dos usuários
data "aws_caller_identity" "current" {}

# Concede permissões corretas aos usuários
resource "aws_iam_user_policy_attachment" "eks_admin" {
  for_each   = toset(var.eks_users)
  user       = each.value
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSAdminPolicy"
}

# Cria IAM Access Entries para os usuários no EKS
resource "aws_eks_access_entry" "users" {
  for_each      = toset(var.eks_users)
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"
  type          = "STANDARD"
}
