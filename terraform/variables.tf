variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC"
}

variable "public_subnet_id" {
  type        = string
  description = "ID of an existing public subnet"
}

variable "private_subnet_id" {
  type        = string
  description = "ID of an existing private subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block of the existing private subnet"
}

variable "private_route_table_id" {
  type        = string
  description = "Route table ID for the existing private subnet"
}

variable "nat_ami_id" {
  type        = string
  description = "AMI ID for the NAT instance (or your custom NAT AMI)"
}

variable "nat_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for the NAT"
}

variable "name_prefix" {
  type        = string
  default     = "my-nat"
  description = "Prefix for naming NAT-related resources"
}
