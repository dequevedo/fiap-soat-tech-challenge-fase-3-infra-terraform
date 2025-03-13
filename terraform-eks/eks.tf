module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true
  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.small"]

    node_security_group_tags = {
      "kubernetes.io/cluster/${local.name}" = null
    }
  }

  eks_managed_node_groups = {
    amc-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

  tags = local.tags
}

### IAM Access Entries
resource "aws_iam_user" "poc_terraform_user" {
  name = "poc-terraform-user"
}

resource "aws_iam_policy_attachment" "eks_admin" {
  name       = "eks_admin_attachment"
  users      = [aws_iam_user.poc_terraform_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSAdminPolicy"
}

resource "aws_iam_policy_attachment" "eks_cluster_admin" {
  name       = "eks_cluster_admin_attachment"
  users      = [aws_iam_user.poc_terraform_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterAdminPolicy"
}

resource "aws_iam_policy_attachment" "eks_edit" {
  name       = "eks_edit_attachment"
  users      = [aws_iam_user.poc_terraform_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSEditPolicy"
}

resource "aws_iam_policy_attachment" "eks_view" {
  name       = "eks_view_attachment"
  users      = [aws_iam_user.poc_terraform_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSViewPolicy"
}
