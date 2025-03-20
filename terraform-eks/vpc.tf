module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "tech-challenge-vpc"
  cidr = "10.0.0.0/22"  # Mesmo range da VPC existente

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26"]
  public_subnets  = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
