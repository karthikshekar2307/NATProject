output "nat_instance_id" {
  description = "NAT instance ID"
  value       = module.nat_instance.nat_instance_id
}

output "nat_private_eni_ip" {
  description = "Private IP of the NAT's private ENI"
  value       = module.nat_instance.nat_private_eni_private_ip
}
