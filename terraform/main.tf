#######################################
# Local variable for NAT user data (optional)
#######################################
locals {
  nat_user_data = <<-EOT
    #!/bin/bash
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    yum install -y iptables-services

    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

    service iptables save
    systemctl enable iptables
  EOT
}

#######################################
# NAT INSTANCE MODULE
#######################################
module "nat_instance" {
  source               = "./modules/nat_instance"
  name_prefix         = var.name_prefix
  vpc_id              = var.vpc_id
  public_subnet_id    = var.public_subnet_id
  private_subnet_id   = var.private_subnet_id
  private_subnet_cidr = var.private_subnet_cidr
  aws_region          = var.aws_region

  ami_id        = var.nat_ami_id
  instance_type = var.nat_instance_type
  user_data     = local.nat_user_data
}

#######################################
# Route for the Private Subnet
#######################################
# Use the NAT instance's private ENI as the next hop for 0.0.0.0/0
resource "aws_route" "private_nat_route" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance.nat_private_eni_id
  depends_on             = [module.nat_instance]
}
