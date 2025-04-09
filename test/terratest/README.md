# Terratest for GitLab Runners Module

This directory contains Terratest tests for the GitLab runners Terraform module. These tests deploy actual infrastructure in AWS to validate that the module works as expected in a real environment.

## Prerequisites

1. Go 1.16 or later
2. AWS credentials with permissions to create resources
3. AWS CLI configured with appropriate credentials
4. Terraform CLI installed

## Test Structure

- `fixtures/`: Contains the Terraform configuration used for testing
- `gitlab_runner_test.go`: Consolidated test file containing all test functions

## Running Tests

### Required Environment Variables

Before running the tests, you need to set the following environment variables:

```bash
# Required AWS resource IDs
export TEST_VPC_ID="vpc-xxxxxxxx"       # Your VPC ID
export TEST_SUBNET_ID="subnet-xxxxxxxx" # Your Subnet ID
export TEST_AMI_ID="ami-xxxxxxxx"      # Amazon Linux 2 AMI ID
```

You can find these values using the AWS CLI or AWS Console. For example:

```bash
# Get default VPC ID
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text --region us-west-2

# Get a subnet ID in the default VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$TEST_VPC_ID" --query "Subnets[0].SubnetId" --output text --region us-west-2

# Get latest Amazon Linux 2 AMI ID
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2" "Name=state,Values=available" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text --region us-west-2
```

### Running the Tests

```bash
# Initialize Go modules (first time only)
go mod tidy

# Run all tests (this will create actual AWS resources)
go test -v -timeout 30m

# Run a specific test section
go test -v -timeout 30m -run TestGitLabRunnerBasicInfrastructure
go test -v -timeout 30m -run TestGitLabRunnerNetworkConfiguration
go test -v -timeout 30m -run TestGitLabRunnerIamRole
go test -v -timeout 30m -run TestGitLabRunnerSecurityGroups

# Skip tests without setting environment variables
export SKIP_TERRATEST=true
go test -v -timeout 30m

# Run tests with verbose AWS SDK logging
AWS_SDK_GO_V2_DEBUG=true go test -v -timeout 30m
```

## Test Sections

The test file `gitlab_runner_test.go` contains the following test functions:

### Infrastructure Tests
- `TestGitLabRunnerBasicInfrastructure`: Validates EC2 instance creation and basic infrastructure deployment
- `TestGitLabRunnerSecurityGroups`: Validates security group creation and configuration

### IAM Tests
- `TestGitLabRunnerIamRole`: Validates IAM role creation and permissions

### Network Tests
- `TestGitLabRunnerNetworkConfiguration`: Validates network settings (subnet, public IP)

## Important Notes

- These tests create actual AWS resources and may incur costs
- Tests automatically clean up resources after completion
- The default timeout is 30 minutes to allow for resource creation and cleanup
- Tests use the default VPC and subnets in the specified AWS region
- The GitLab runner token used in tests is a dummy token for testing purposes only

## Troubleshooting

If tests fail during cleanup, you may need to manually remove resources:
1. EC2 instances with the name prefix "terratest-runner"
2. Security groups with the name prefix "terratest-runner"
3. IAM roles with the name prefix "terratest-runner"

You can use the AWS Management Console or AWS CLI to find and remove these resources.
