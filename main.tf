variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for GitLab runner"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "enable_ssm" {
  description = "Enable Systems Manager for instance management instead of SSH"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "gitlab_url" {
  description = "GitLab URL for runner registration"
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_runner_token" {
  description = "GitLab runner registration token"
  type        = string
  sensitive   = true
}

variable "runner_tags" {
  description = "Tags to assign to the GitLab runner"
  type        = list(string)
  default     = []
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "gitlab-runner"
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to the instance"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# No additional variables needed for Docker executor

resource "aws_security_group" "gitlab_runner" {
  name        = "${var.instance_name}-sg"
  description = "Security group for GitLab runner"
  vpc_id      = var.vpc_id

  # Allow all traffic between runners in the same security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
    description     = "Allow all traffic between runners"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name = "${var.instance_name}-sg"
    },
    var.tags
  )
}

# No worker security group needed for Docker executor

resource "aws_iam_role" "gitlab_runner_role" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.instance_name}-role"
    },
    var.tags
  )
}

# Attach SSM policy if SSM is enabled
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.gitlab_runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# SSM policy is sufficient for basic Docker executor

resource "aws_iam_instance_profile" "gitlab_runner_profile" {
  name = "${var.instance_name}-instance-profile"
  role = aws_iam_role.gitlab_runner_role.name
}

variable "assign_public_ip" {
  description = "Assign a public IP to the instance. Required if not using a NAT gateway."
  type        = bool
  default     = false
}

resource "aws_instance" "gitlab_runner" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = concat([aws_security_group.gitlab_runner.id], var.additional_security_group_ids)
  iam_instance_profile        = aws_iam_instance_profile.gitlab_runner_profile.name
  associate_public_ip_address = var.assign_public_ip

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    gitlab_url          = var.gitlab_url
    gitlab_runner_token = var.gitlab_runner_token
    runner_tags         = join(",", var.runner_tags)
  })

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}

# Remove Elastic IP to avoid exposing public IP