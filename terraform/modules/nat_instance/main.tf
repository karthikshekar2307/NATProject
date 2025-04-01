#############################
# NAT Instance Module
#############################

resource "aws_security_group" "natsg" {
  name        = "${var.name_prefix}-nat-sg"
  description = "Security Group for NAT instance"
  vpc_id      = var.vpc_id

  # Ingress rule #1: ephemeral ports from private subnet
  ingress {
    description      = "Allow inbound ephemeral from private subnet"
    from_port        = 1024
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr]
  }

  # Ingress rule #2: SSH inbound from your IP
  ingress {
    description      = "SSH from your IP"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_ssh_cidr]
  }

  # Egress rule: allow outbound anywhere
  egress {
    description      = "Outbound to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-nat-sg"
  }
}

resource "aws_network_interface" "public_eni" {
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.natsg.id]

  tags = {
    Name = "${var.name_prefix}-public-eni"
  }
}

resource "aws_network_interface" "private_eni" {
  subnet_id       = var.private_subnet_id
  security_groups = [aws_security_group.natsg.id]

  tags = {
    Name = "${var.name_prefix}-private-eni"
  }
}

resource "aws_instance" "natinstance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # Remove associate_public_ip_address entirely if you’re specifying network_interface blocks

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.public_eni.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.private_eni.id
  }

  user_data = var.user_data

  tags = {
    Name = "${var.name_prefix}-nat-instance"
  }

  # Disable source/dest check
  # We'll run a local-exec to modify instance attribute
  provisioner "local-exec" {
    command = <<EOT
      aws ec2 modify-instance-attribute --instance-id ${self.id} --no-source-dest-check --region ${var.aws_region}
    EOT
  }
}
