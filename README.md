## Requirements
- AWS CLI
- Terraform CLI

## AWS Profiles

Obter profiles da AWS
```sh
aws configure list-profiles
```

Obter detalhes do profile da AWS atual
```sh
aws configure list
```

Caso não possuir nenhum profile, criar um novo utilizando suas credenciais da AWS.
```sh
aws configure --profile meu-novo-perfil
```

## Terraform

Inicializar o Terraform
```sh
terraform init
```

Verificar tudo que o Terraform fará
```sh
terraform plan
```

Aplicar o Terraform
```sh
terraform apply -auto-approve
```

Remover tudo que o Terraform criou
```sh
terraform destroy -auto-approve
```


