# Security Group para o Load Balancer
resource "aws_security_group" "sg" {
  name        = "tech-challenge-nlb-sg"
  description = "Security group for the internal NLB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech-challenge-nlb-sg"
  }
}

# Load Balancer Interno (NLB)
resource "aws_lb" "internal_nlb" {
  name               = "tech-challenge-nlb-internal"
  internal           = true  # Define como Load Balancer interno
  load_balancer_type = "network"
  security_groups    = [aws_security_group.sg.id]
  subnets            = module.vpc.private_subnets

  enable_deletion_protection = false

  tags = {
    Name = "tech-challenge-lb-internal"
  }
}

# Target Group associado ao Load Balancer
resource "aws_lb_target_group" "target_group" {
  name     = "tech-challenge-target-group"
  port     = 8080
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval = 30
    path     = "/health"
    port     = 8080
    protocol = "HTTP"
    timeout  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener para o Load Balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "8080"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}