provider "aws" {
  profile = "dequevedo-aws-profile"
  region  = "us-east-1"
}

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Permite acesso na porta 8080"

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
}

resource "aws_instance" "web_server" {
  ami           = "ami-05b10e08d247fb927"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "<h1>Hello, World!</h1>" | sudo tee /usr/share/nginx/html/index.html
    sudo sed -i 's/listen       80;/listen 8080;/' /etc/nginx/nginx.conf
    sudo systemctl restart nginx
  EOF

  tags = {
    Name = "WebServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}
