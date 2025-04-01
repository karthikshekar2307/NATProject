variable "name_prefix" {
  type        = string
  description = "Prefix for naming NAT resources"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "public_subnet_id" {
  type        = string
  description = "Subnet ID for the public interface"
}

variable "private_subnet_id" {
  type        = string
  description = "Subnet ID for the private interface"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block of the private subnet, used for SG inbound ephemeral rules"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH into NAT instance"
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  type        = string
  description = "AMI for NAT instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for NAT instance"
  default     = "t3.micro"
}

variable "user_data" {
  type        = string
  description = "User data script to enable IP forwarding, iptables, etc."
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "Region for AWS CLI calls (used by local-exec to disable src/dest check)"
}
