output "nat_instance_id" {
  description = "The ID of the NAT EC2 instance"
  value       = aws_instance.natinstance.id
}

output "nat_public_eni_id" {
  description = "The ID of the NAT's public ENI"
  value       = aws_network_interface.public_eni.id
}

output "nat_private_eni_id" {
  description = "The ID of the NAT's private ENI"
  value       = aws_network_interface.private_eni.id
}

output "nat_private_eni_private_ip" {
  description = "The private IP of the NAT's private ENI"
  value       = aws_network_interface.private_eni.private_ip
}
