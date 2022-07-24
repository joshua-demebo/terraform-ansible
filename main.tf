locals {
  ami_id           = "ami-052efd3df9dad4825"
  vpc_id           = "vpc-0f899a2630c0d27b3"
  ssh_user         = "ubuntu"
  key_name         = "sun-keypair"
  private_key_path = "/home/labsuser/remoteexec/sun-keypair.pem"
}

provider "aws" {
  access_key = "ASIAYX46KLMELYYFZNHU"
  secret_key = "df1WNEzDTdZ6X5ykes976wELJ47Jh4o8FQVfme0m"
  token      = "FwoGZXIvYXdzEFgaDBJ39pbPuoRrC/l82iK4AVFRB0WIUlSCvuc3F6EHITzCKjehAfrBlwVK96cAohu1ADZ3lrasYEDOstF+RCBGKKmAMahno2/e/FRbabrbggNaffYBQffMSlfz4M5XzrR8QiWnlw3iiZ4JGUjqY37GC4AsscILt/rdqjg1AAiBoqLel32KEAJGs5sO0G/Iw0emYrDQLzlQSyOkiZ+GNyQ7TEogRVzo2kmSzAUNeoVj97hZCAMl3DpbqQSU3j8BtJNUkyHu+jAfo3koxq71lgYyLbZj7JfIAMtGHENKLdjzlC9ykYks4uiul511LHddfA8MXa6BSbEF5k350CidCA=="
  region     = "us-east-1"
}

resource "aws_security_group" "demoaccess" {
  name   = "demoaccess"
  vpc_id = local.vpc_id

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

resource "aws_instance" "web" {
  ami                         = local.ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.demoaccess.id]
  key_name                    = local.key_name

  tags = {
    Name = "Demo test"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = local.ssh_user
    private_key = file(local.private_key_path)
    timeout     = "4m"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > myhosts"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i myhosts --private_key ${local.private_key_path} varloop.yml
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

