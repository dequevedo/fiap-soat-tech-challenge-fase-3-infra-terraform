provider "aws" {
  profile = "dequevedo-aws-profile"
  region  = "us-east-1"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet"
  }
}

resource "aws_route_table" "k8s_public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "k8s-public-route-table"
  }
}

resource "aws_route_table_association" "k8s_public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.k8s_public_rt.id
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-security-group"
  description = "Permite acesso SSH e Kubernetes"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite SSH de qualquer lugar
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso ao API Server do Kubernetes
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso aos serviços NodePort
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = "ami-05b10e08d247fb927"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = "terraform-kubernetes"

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    LOG_FILE="/var/log/user_data.log"

    # Redireciona toda saída para um log
    exec > >(tee -a "$LOG_FILE") 2>&1

    echo "==== Iniciando provisionamento ===="

    # Função para verificar conectividade
    function check_connectivity {
      echo "Verificando conexão com a internet..."
      ping -c 3 8.8.8.8 || (echo "Falha na conexão com a internet!" && exit 1)
    }

    check_connectivity

    # Atualiza a máquina
    echo "Atualizando pacotes do sistema..."
    sudo yum update -y || echo "Aviso: Falha ao atualizar pacotes!"

    # Instala EC2 Instance Connect
    echo "Instalando EC2 Instance Connect..."
    sudo yum install -y ec2-instance-connect
    sudo systemctl enable --now ec2-instance-connect

    # Reinicia o SSH para garantir a conexão
    sudo systemctl restart sshd

    # Instala K3s (Kubernetes leve) com retry
    echo "Instalando K3s..."
    for i in {1..5}; do
      curl -sfL https://get.k3s.io | sh - && break
      echo "Tentativa $i de instalação do K3s falhou. Tentando novamente em 10s..."
      sleep 10
    done

    # Espera o cluster subir
    sleep 30

    # Verifica se o K3s está rodando
    sudo systemctl status k3s || (echo "Erro: K3s não está rodando!" && exit 1)

    # Copia o kubeconfig para ser acessível
    mkdir -p /home/ec2-user/.kube
    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
      sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
      sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config
      echo "K3s instalado com sucesso! Acesse com kubectl"
    else
      echo "Erro: O arquivo k3s.yaml não foi encontrado. K3s pode não ter sido instalado corretamente."
    fi
  EOF

  tags = {
    Name = "k8s-master"
  }
}

output "instance_public_ip" {
  value = aws_instance.k8s_master.public_ip
}