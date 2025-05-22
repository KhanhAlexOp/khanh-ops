provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

resource "aws_security_group" "allow_web_ssh" {
  name        = "allow_web_ssh"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "dev_server" {
  ami                    = var.aws_ami 
  instance_type          = "t2.micro"
  key_name               = var.aws_ssh_key         
  security_groups        = [aws_security_group.allow_web_ssh.name]
  user_data              = file("install_docker.sh")  
  tags = {
    Name = "KhanhDevOps"
  }

  # File provisioner to upload docker-compose.yml
  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"  
      private_key = file("./../aws_config/khanh-devops.pem")  
      host        = self.public_ip
    }
  }

  # Upload install_docker.sh
provisioner "file" {
  source      = "install_docker.sh"
  destination = "/home/ubuntu/install_docker.sh"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./../aws_config/khanh-devops.pem")
    host        = self.public_ip
  }
}

  # Remote-exec provisioner to run docker-compose command
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/install_docker.sh",
      "sudo /home/ubuntu/install_docker.sh",
      "sudo docker-compose -f /home/ubuntu/docker-compose.yml up -d"  
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  
      private_key = file("./../aws_config/khanh-devops.pem")  
      host        = self.public_ip
    }
  }
}

output "instance_ip" {
  value = aws_instance.dev_server.public_ip
}
