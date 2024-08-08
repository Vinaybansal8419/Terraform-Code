output "vpc_id" {
  value = aws_vpc.nginx_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.nginx_pub_subnet[0].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.nginx_priv_subnet[*].id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.nginx_igw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT gateway"
  value       = aws_nat_gateway.nginx_nat.id
}

output "bastion_instance_id" {
  description = "The ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "private_instance_ids" {
  description = "The IDs of the private instances"
  value = [
    aws_instance.private_instance.id,
    aws_instance.private_instance_2.id
  ]
}
