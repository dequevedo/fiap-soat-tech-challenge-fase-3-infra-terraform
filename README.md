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

Definir um profile como ativo
```sh
export AWS_PROFILE=dequevedo-aws-profile
```

Obter o profile ativo
```sh
aws sts get-caller-identity --profile dequevedo-aws-profile
```

Atualizando o kubeconfig com as credenciais corretas
```sh
aws eks --region us-east-1 update-kubeconfig --name fiap-fase3-cluster --profile dequevedo-aws-profile
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

## Acessar a aplicação
1. Garantir que está rodando o proxy para acessar o LoadBalancer:
```sh
aws eks update-kubeconfig --name fiap-fase3-cluster --region us-east-1 --profile dequevedo-aws-profile
```

2. Garantir que os comandos do Helm/K8s foram executados e os PODs e LoadBalancer estão rodando:

3. Obter a URL do LoadBalancer
```sh
kubectl get svc
```

4. Algo assim será deve ser retornado:
```
NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)          AGE
fiap-tech-challenge-app   LoadBalancer   172.20.156.81    a11111119984d4281b0cb1111111db-1111111111.us-east-1.elb.amazonaws.com   8080:32005/TCP   5s
```

5. Fazer um GET:
```sh
curl --location 'http://a11111119984d4281b0cb1111111db-1111111111.us-east-1.elb.amazonaws.com:8080/orders'
```
Lembre-se de trocar o endereço acima pelo que foi retornado no passo 3.




