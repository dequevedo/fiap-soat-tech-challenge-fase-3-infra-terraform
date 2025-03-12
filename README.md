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

## Visualizar o cluster utilizando Lens ou Monokle

1. Verificar quais Contextos do K8s você possui na máquina atualmente:
```sh
kubectl config get-contexts
```

2. Criar um novo Contexto do K8s para acessar o EKS da AWS:
```sh
aws eks update-kubeconfig --name fiap-fase3-cluster --region us-east-1 --profile dequevedo-aws-profile
```
Lembre-se de passar o ```sh --profile dequevedo-aws-profile``` com o nome correto do seu profile da AWS que possui as credenciais de acesso ao EKS.

3. Verificar se o novo Contexto foi criado corretamente:
```sh
kubectl config get-contexts
```

Algo assim deve aparecer:
```
CURRENT   NAME                                                            CLUSTER                                                         AUTHINFO                                                        NAMESPACE
*         arn:aws:eks:us-east-1:123456:cluster/fiap-fase3-cluster   arn:aws:eks:us-east-1:123456:cluster/fiap-fase3-cluster   arn:aws:eks:us-east-1:123456:cluster/fiap-fase3-cluster
          docker-desktop                                                  docker-desktop                                                  docker-desktop
```

Note que o * define qual o contexto atual, portanto, já pode ser utilizado para acessar o Lens.




