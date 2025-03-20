resource "aws_ecr_repository" "tech_challenge_repo" {
  name = "tech-challenge/fiap-soat-tech-challenge-fase-3-app"
  image_scanning_configuration {
    scan_on_push = true
  }
}