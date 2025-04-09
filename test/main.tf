provider "aws" {
  region  = "us-east-1"
  # Use your own AWS profile or remove this line to use default credentials
  # profile = "your-aws-profile"
}

# Get latest Amazon Linux 2 AMI
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

module "gitlab_runner" {
  source = "../."

  instance_type       = "t3.medium"
  ami_id              = data.aws_ami.amazon_linux_2.id
  subnet_id           = local.subnet_id
  vpc_id              = data.aws_vpc.default.id
  gitlab_url          = "https://gitlab.com"
  gitlab_runner_token = "your-gitlab-runner-token" # Replace with your actual GitLab runner token
  runner_tags         = ["docker", "aws"]
  instance_name       = "gitlab-runner-test"
  enable_ssm          = true
  assign_public_ip    = true
  # Using standard Docker executor
}

output "runner_private_ip" {
  value = module.gitlab_runner.instance_private_ip
}

output "runner_public_ip" {
  value = module.gitlab_runner.instance_public_ip
}

output "runner_instance_id" {
  value = module.gitlab_runner.instance_id
}