variable "s3_bucket" {
  description = "Nome do bucket S3 para armazenar o state do Terraform"
  type        = string
}

variable "dynamodb_table" {
  description = "Nome da tabela DynamoDB para locking do Terraform"
  type        = string
}
