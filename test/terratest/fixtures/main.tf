provider "aws" {
  region = "us-west-2"
  profile = "devops-toryordonline"
}

locals {
  # Use a placeholder token for testing
  runner_token = "test-token-placeholder"
  gitlab_url   = "https://gitlab.com"
}

module "gitlab_runner" {
  source = "../../../"

  instance_name       = var.instance_name
  vpc_id              = var.vpc_id
  subnet_id           = var.subnet_id
  ami_id              = var.ami_id
  instance_type       = "t3.micro"
  gitlab_runner_token = local.runner_token
  gitlab_url          = local.gitlab_url
  assign_public_ip    = true
  enable_ssm          = true
  runner_tags         = ["terratest", "docker"]
  additional_security_group_ids = []
}
