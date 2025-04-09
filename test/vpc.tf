# Query the default VPC
data "aws_vpc" "default" {
  default = true
}

# Query all default subnets
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Query public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  # Check for subnets where map-public-ip-on-launch is true (public subnets)
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# If there are public subnets, use the first one; otherwise, use the first available subnet
locals {
  subnet_ids = length(data.aws_subnets.public.ids) > 0 ? data.aws_subnets.public.ids : data.aws_subnets.all.ids
  subnet_id  = length(local.subnet_ids) > 0 ? tolist(local.subnet_ids)[0] : null
}

output "vpc_id" {
  description = "Default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet ID to use for GitLab runner"
  value       = local.subnet_id
}