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

Caso não possuir nenhum profile, criar um novo utilizando suas credenciais da AWS. Tenha em mãos o Access Key e Secret Key de um usuário da AWS dedicado ao terraform.
```sh
aws configure --profile meu-novo-perfil
```

Definir um profile como ativo
```sh
export AWS_PROFILE=default
```

Obter o profile ativo
```sh
aws sts get-caller-identity --profile default
```

Atualizando o kubeconfig com as credenciais corretas
```sh
aws eks --region us-east-1 update-kubeconfig --name tech-challenge-cluster --profile default
```

## Terraform

Inicializar o Terraform
```sh
terraform -chdir=terraform-eks init
```

Verificar tudo que o Terraform fará
```sh
terraform -chdir=terraform-eks plan
```

Aplicar o Terraform
```sh
terraform -chdir=terraform-eks apply -auto-approve
```

Remover tudo que o Terraform criou
```sh
terraform -chdir=terraform-eks destroy -auto-approve
```

## Visualizar o cluster utilizando Lens ou Monokle

1. Verificar quais Contextos do K8s você possui na máquina atualmente:
```sh
kubectl config get-contexts
```

2. Criar um novo Contexto do K8s para acessar o EKS da AWS:
```sh
aws eks update-kubeconfig --name tech-challenge-cluster --region us-east-1 --profile default
```
Lembre-se de passar o ```sh --profile default``` com o nome correto do seu profile da AWS que possui as credenciais de acesso ao EKS.

3. Verificar se o novo Contexto foi criado corretamente:
```sh
kubectl config get-contexts
```

Algo assim deve aparecer:
```
CURRENT   NAME                                                            CLUSTER                                                         AUTHINFO                                                        NAMESPACE
*         arn:aws:eks:us-east-1:123456:cluster/tech-challenge-cluster   arn:aws:eks:us-east-1:123456:cluster/tech-challenge-cluster   arn:aws:eks:us-east-1:123456:cluster/tech-challenge-cluster
          docker-desktop                                                  docker-desktop                                                  docker-desktop
```

Note que o * define qual o contexto atual, portanto, já pode ser utilizado para acessar o Lens.

## Acessar a aplicação
1. Garantir que está rodando o proxy para acessar o LoadBalancer:
```sh
aws eks update-kubeconfig --name tech-challenge-cluster --region us-east-1 --profile default
```

2. Garantir que os comandos do Helm/K8s foram executados e os PODs e LoadBalancer estão rodando.
Isso deve ser feito no repositório que contém a aplicação e os arquivos de configuração do Helm e Kubernetes. 
Provavelmente será algo como ```helm install ...``` ou ```kubectl apply ...```

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
