# AWS Region
variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "172.31.0.0/16"
}

# Public Subnet Count
variable "pub_subnet_count" {
  description = "The number of public subnets to create."
  default     = 1
}

# Private Subnet Count
variable "priv_subnet_count" {
  description = "The number of private subnets to create."
  default     = 2
}

# Availability Zones
variable "availability_zones" {
  description = "The availability zones to use for subnets."
  default     = ["us-east-1a", "us-east-1b"]
}

# AMI ID
variable "ami_id" {
  description = "The AMI ID to use for instances."
  default     = "ami-03b9bf7822474e16b" # Replace with the desired AMI ID
}

# Bastion Instance Type
variable "bastion_instance_type" {
  description = "The instance type for the bastion host."
  default     = "t2.micro"
}

# Private Instance Type
variable "private_instance_type" {
  description = "The instance type for the private instances."
  default     = "t2.micro"
}

# SSH Key Name
variable "key_name" {
  description = "The SSH key name to use for instances."
  default     = "vinay1" # Replace with your SSH key name
}
