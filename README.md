# GitLab Private Runners Terraform Module

[![GitHub](https://img.shields.io/github/license/amaudy/aws-gitlab-private-runner-docker)](https://github.com/amaudy/aws-gitlab-private-runner-docker/blob/main/LICENSE)

## Overview

This module provisions an EC2 instance and configures it as a GitLab private runner with Docker executor. It supports both Amazon Linux 2 and Ubuntu AMIs.

## Usage

```hcl
module "gitlab_runner" {
  source = "github.com/amaudy/aws-gitlab-private-runner-docker"

  aws_region          = "us-east-1"
  instance_type       = "t3.micro"
  ami_id              = "ami-0123456789abcdef0"  # Amazon Linux 2 or Ubuntu AMI
  enable_ssm          = true  # Enable SSM for instance management
  assign_public_ip    = true  # Assign public IP if NAT gateway is not available
  subnet_id           = "subnet-0123456789abcdef0"
  vpc_id              = "vpc-0123456789abcdef0"
  gitlab_url          = "https://gitlab.com"
  gitlab_runner_token = "glrt-XXXXXXXXXXXXXXXXXXXX" # Replace with your actual GitLab runner registration token
  runner_tags         = ["docker", "aws"]
  instance_name       = "gitlab-runner-prod"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| instance_type | EC2 instance type for GitLab runner | `string` | `"t3.micro"` | no |
| ami_id | AMI ID to use for the EC2 instance | `string` | n/a | yes |
| enable_ssm | Enable Systems Manager for instance management instead of SSH | `bool` | `true` | no |
| assign_public_ip | Assign a public IP to the instance. Required if not using a NAT gateway. | `bool` | `false` | no |
| subnet_id | Subnet ID where EC2 instance will be deployed | `string` | n/a | yes |
| vpc_id | VPC ID for security group | `string` | n/a | yes |
| gitlab_url | GitLab URL for runner registration | `string` | `"https://gitlab.com"` | no |
| gitlab_runner_token | GitLab runner registration token | `string` | n/a | yes |
| runner_tags | Tags to assign to the GitLab runner | `list(string)` | `[]` | no |
| instance_name | Name for the EC2 instance | `string` | `"gitlab-runner"` | no |
| additional_security_group_ids | Additional security group IDs to attach to the instance | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_public_ip | Public IP address of the EC2 instance |
| instance_private_ip | Private IP address of the EC2 instance |
| security_group_id | ID of the security group created for the GitLab runner |

## Notes

- The module creates a security group allowing SSH access and outbound internet access.
- GitLab runner is installed and registered automatically via user data script.
- Docker executor is configured by default.
- Remember to keep your GitLab runner token secure.

## Testing

This module includes automated tests to validate the Terraform configuration. The tests use pytest and focus on validating the module structure and configuration without requiring actual AWS resources to be created.

1. **Static Analysis Tests** (Python/pytest): Validate the Terraform configuration without creating real resources
2. **Infrastructure Tests** (Go/Terratest): Deploy and test actual infrastructure in AWS

### Static Analysis Tests

To run the static analysis tests:

1. Set up a Python virtual environment:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

2. Run the tests:

```bash
python -m pytest tests/test_gitlab_runner.py -v
```

#### Static Test Coverage

These tests validate:

1. Terraform configuration syntax
2. Module structure and required files
3. Output definitions
4. User data script configuration
5. Required AWS resources (security groups, IAM roles, EC2 instances)

### Infrastructure Tests with Terratest

Terratest is a Go library that allows you to test your infrastructure by deploying real resources in AWS. These tests provide higher confidence that your module works as expected in a real environment.

#### Prerequisites

1. Go 1.16 or later
2. AWS credentials with permissions to create resources
3. AWS CLI configured with appropriate credentials

#### Running Terratest Tests

```bash
cd test/terratest
go test -v -timeout 30m
```

> **Note**: These tests create actual AWS resources and may incur costs. The tests automatically clean up resources after completion, but you should monitor your AWS account to ensure all resources are properly destroyed.

#### Terratest Coverage

These tests validate:

1. EC2 instance creation and configuration
2. Security group rules and settings
3. IAM roles and permissions
4. GitLab runner installation and configuration
5. Docker installation and configuration
6. System Manager (SSM) integration

## Security Scanning

This module includes security scanning with Checkov, a static code analysis tool for infrastructure-as-code. Checkov scans for security and compliance issues in Terraform configurations.

### Running Security Scans

```bash
# Activate the virtual environment
source venv/bin/activate

# Run Checkov scans through pytest
python -m pytest tests/test_checkov.py -v

# Or run Checkov directly on the module
checkov -d . --framework terraform
```

The scan results are saved in the `scan_results` directory in JSON format for further analysis. These scans help identify potential security issues such as:

- Unencrypted resources
- Overly permissive security groups
- Missing IAM best practices
- Insecure defaults

It's recommended to run these scans regularly and before deploying changes to production.

## Installation

To use this module in your Terraform configuration, add the following:

```hcl
module "gitlab_runner" {
  source = "github.com/amaudy/aws-gitlab-private-runner-docker"

  # Required parameters
  ami_id              = "ami-0123456789abcdef0"  # Amazon Linux 2 or Ubuntu AMI
  subnet_id           = "subnet-0123456789abcdef0"
  vpc_id              = "vpc-0123456789abcdef0"
  gitlab_runner_token = "glrt-XXXXXXXXXXXXXXXXXXXX" # Replace with your actual GitLab runner token
  
  # Optional parameters with defaults
  aws_region          = "us-east-1"
  instance_type       = "t3.micro"
  enable_ssm          = true
  assign_public_ip    = false
  gitlab_url          = "https://gitlab.com"
  runner_tags         = ["docker", "aws"]
  instance_name       = "gitlab-runner"
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.