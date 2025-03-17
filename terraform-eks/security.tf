resource "aws_security_group_rule" "allow_eks_30090" {
  type              = "ingress"
  from_port         = 30080
  to_port           = 30080
  protocol         = "tcp"
  security_group_id = module.eks.cluster_security_group_id
  cidr_blocks      = ["0.0.0.0/0"]
}