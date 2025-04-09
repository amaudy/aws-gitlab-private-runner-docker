variable "vpc_id" {
  description = "The ID of the VPC to deploy the GitLab runner in"
  type        = string
  default     = "vpc-12345678" # This will be overridden in the test
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy the GitLab runner in"
  type        = string
  default     = "subnet-12345678" # This will be overridden in the test
}

variable "ami_id" {
  description = "The ID of the AMI to use for the GitLab runner instance"
  type        = string
  default     = "ami-12345678" # This will be overridden in the test
}

variable "instance_name" {
  description = "The name to assign to the GitLab runner instance"
  type        = string
  default     = "terratest-runner"
}
