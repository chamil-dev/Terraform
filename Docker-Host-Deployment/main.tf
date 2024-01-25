provider "aws" {
  region = "us-east-1"
}

locals {
  ami_id  = "ami-0c7217cdde317cfec"
  vm_type = "t2.micro"
}


resource "aws_instance" "docker-host" {
  ami             = local.ami_id
  instance_type   = local.vm_type
  security_groups = [aws_security_group.docker-host-sg.name]
  key_name        = "cmbkey"
  tags = {
    "Name" = "Docker-host-Ubuntu "
  }

  user_data = <<-EOF
#!/bin/bash
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg 
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
              EOF

}

resource "aws_security_group" "docker-host-sg" {
  name        = "controler-sg"
  description = "Allow SSH from local PC"

  ingress {
    from_port   = 22
    to_port     = 22
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

output "docker_host_publi_ip" {
  value = aws_instance.docker-host.public_ip
}

