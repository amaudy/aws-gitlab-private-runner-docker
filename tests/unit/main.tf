provider "aws" {
  region  = "us-east-1"
  profile = "devops-toryordonline"
}

# Use a data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get default VPC and subnet for testing
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# This is a mock module configuration for testing
# It will not be actually applied during tests
module "gitlab_runner_test" {
  source = "../.."

  aws_region          = "us-east-1"
  instance_type       = "t3.micro"
  ami_id              = data.aws_ami.amazon_linux_2.id
  enable_ssm          = true
  assign_public_ip    = true
  subnet_id           = tolist(data.aws_subnets.all.ids)[0]
  vpc_id              = data.aws_vpc.default.id
  gitlab_url          = "https://gitlab.com"
  gitlab_runner_token = "mock-token-for-testing"
  runner_tags         = ["test", "docker"]
  instance_name       = "gitlab-runner-test-unit"
}
