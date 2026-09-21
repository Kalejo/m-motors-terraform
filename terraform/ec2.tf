# Recherche automatique de la dernière image officielle Ubuntu 24.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Machine virtuelle de développement en instance Spot
resource "aws_instance" "development" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public_a.id
  associate_public_ip_address = true

  key_name = var.ec2_key_name

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  # Instance Spot persistante pouvant être arrêtée puis redémarrée
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  # Oblige l'utilisation du service de métadonnées sécurisé IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Disque système chiffré
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  # Installation automatique de Git, Docker et AWS CLI via cloud-init
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y git docker.io awscli
  EOF

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-development"
    Environment = "development"
  }
}

