resource "aws_security_group" "eks_sg" {
  name        = "eks-cluster-sg"
  description = "Security Group fixo para o cluster EKS"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "eks-cluster-sg"
  }
}

resource "aws_security_group_rule" "allow_eks_30090" {
  type              = "ingress"
  from_port         = 30080
  to_port           = 30080
  protocol         = "tcp"
  security_group_id = aws_security_group.eks_sg.id
  cidr_blocks = [module.vpc.vpc_cidr_block]
}