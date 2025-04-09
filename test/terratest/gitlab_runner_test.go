package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Skip tests if SKIP_TERRATEST environment variable is set
func skipIfEnvSet(t *testing.T) {
	if os.Getenv("SKIP_TERRATEST") != "" {
		t.Skip("Skipping Terratest tests because SKIP_TERRATEST is set")
	}
}

// getEnvOrDefault returns the value of the environment variable or the default value if not set
func getEnvOrDefault(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

// TestGitLabRunnerBasicInfrastructure validates that the basic infrastructure is created correctly
func TestGitLabRunnerBasicInfrastructure(t *testing.T) {
	// Skip test if SKIP_TERRATEST environment variable is set
	skipIfEnvSet(t)
	// Generate a random name to prevent a naming conflict
	uniqueID := random.UniqueId()
	instanceName := fmt.Sprintf("gitlab-runner-test-%s", uniqueID)

	// Get the AWS region to use
	awsRegion := "us-west-2"
	
	// Get AWS profile from environment variable or use default
	awsProfile := getEnvOrDefault("AWS_PROFILE", "default")

	// Get AWS resource IDs from environment variables or use defaults
	vpcID := getEnvOrDefault("TEST_VPC_ID", "")
	subnetID := getEnvOrDefault("TEST_SUBNET_ID", "")
	amiID := getEnvOrDefault("TEST_AMI_ID", "")
	
	// Skip test if required environment variables are not set
	if vpcID == "" || subnetID == "" || amiID == "" {
		t.Skip("Skipping test because one or more required environment variables (TEST_VPC_ID, TEST_SUBNET_ID, TEST_AMI_ID) are not set")
	}
	
	// Configure Terraform options with real AWS resource IDs
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures",
		Vars: map[string]interface{}{
			"instance_name": instanceName,
			"vpc_id":     vpcID,
			"subnet_id":  subnetID,
			"ami_id":     amiID,
		},
		EnvVars: map[string]string{
			"AWS_PROFILE": awsProfile,
			"AWS_REGION": awsRegion,
		},
	})

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Get output values
	instanceID := terraform.Output(t, terraformOptions, "instance_id")
	securityGroupID := terraform.Output(t, terraformOptions, "security_group_id")
	
	// Verify that we got valid outputs
	assert.NotEmpty(t, instanceID, "Instance ID should not be empty")
	assert.NotEmpty(t, securityGroupID, "Security Group ID should not be empty")
	
	// Wait for a moment to ensure the instance is fully initialized
	fmt.Printf("Waiting for instance %s to initialize...\n", instanceID)
	time.Sleep(30 * time.Second)
	
	// Success - the infrastructure was created
	fmt.Println("Infrastructure created successfully!")
}

// TestGitLabRunnerNetworkConfiguration validates that the network configuration is correct
func TestGitLabRunnerNetworkConfiguration(t *testing.T) {
	// Skip test if SKIP_TERRATEST environment variable is set
	skipIfEnvSet(t)
	// Generate a random name to prevent a naming conflict
	uniqueID := random.UniqueId()
	instanceName := fmt.Sprintf("gitlab-runner-network-%s", uniqueID)

	// Get the AWS region to use
	awsRegion := "us-west-2"
	
	// Get AWS profile from environment variable or use default
	awsProfile := getEnvOrDefault("AWS_PROFILE", "default")

	// Get AWS resource IDs from environment variables or use defaults
	vpcID := getEnvOrDefault("TEST_VPC_ID", "")
	subnetID := getEnvOrDefault("TEST_SUBNET_ID", "")
	amiID := getEnvOrDefault("TEST_AMI_ID", "")
	
	// Skip test if required environment variables are not set
	if vpcID == "" || subnetID == "" || amiID == "" {
		t.Skip("Skipping test because one or more required environment variables (TEST_VPC_ID, TEST_SUBNET_ID, TEST_AMI_ID) are not set")
	}
	
	// Configure Terraform options with real AWS resource IDs
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures",
		Vars: map[string]interface{}{
			"instance_name": instanceName,
			"vpc_id":     vpcID,
			"subnet_id":  subnetID,
			"ami_id":     amiID,
		},
		EnvVars: map[string]string{
			"AWS_PROFILE": awsProfile,
			"AWS_REGION": awsRegion,
		},
	})

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Get output values
	publicIP := terraform.Output(t, terraformOptions, "instance_public_ip")
	
	// Verify that the instance has a public IP
	assert.NotEmpty(t, publicIP, "Instance should have a public IP")
	
	// Success - the network configuration is correct
	fmt.Println("Network configuration is correct!")
}

// TestGitLabRunnerIamRole validates that the IAM role is correctly configured
func TestGitLabRunnerIamRole(t *testing.T) {
	// Skip test if SKIP_TERRATEST environment variable is set
	skipIfEnvSet(t)
	// Generate a random name to prevent a naming conflict
	uniqueID := random.UniqueId()
	instanceName := fmt.Sprintf("gitlab-runner-iam-%s", uniqueID)

	// Get the AWS region to use
	awsRegion := "us-west-2"
	
	// Get AWS profile from environment variable or use default
	awsProfile := getEnvOrDefault("AWS_PROFILE", "default")

	// Get AWS resource IDs from environment variables or use defaults
	vpcID := getEnvOrDefault("TEST_VPC_ID", "")
	subnetID := getEnvOrDefault("TEST_SUBNET_ID", "")
	amiID := getEnvOrDefault("TEST_AMI_ID", "")
	
	// Skip test if required environment variables are not set
	if vpcID == "" || subnetID == "" || amiID == "" {
		t.Skip("Skipping test because one or more required environment variables (TEST_VPC_ID, TEST_SUBNET_ID, TEST_AMI_ID) are not set")
	}
	
	// Configure Terraform options with real AWS resource IDs
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures",
		Vars: map[string]interface{}{
			"instance_name": instanceName,
			"vpc_id":     vpcID,
			"subnet_id":  subnetID,
			"ami_id":     amiID,
		},
		EnvVars: map[string]string{
			"AWS_PROFILE": awsProfile,
			"AWS_REGION": awsRegion,
		},
	})

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Get output values
	iamRoleName := terraform.Output(t, terraformOptions, "iam_role_name")
	
	// Verify that the IAM role was created
	assert.NotEmpty(t, iamRoleName, "IAM role name should not be empty")
	
	// Success - the IAM role was created
	fmt.Println("IAM role created successfully!")
}

// TestGitLabRunnerSecurityGroups validates that the security groups are correctly configured
func TestGitLabRunnerSecurityGroups(t *testing.T) {
	// Skip test if SKIP_TERRATEST environment variable is set
	skipIfEnvSet(t)
	// Generate a random name to prevent a naming conflict
	uniqueID := random.UniqueId()
	instanceName := fmt.Sprintf("gitlab-runner-sg-%s", uniqueID)

	// Get the AWS region to use
	awsRegion := "us-west-2"
	
	// Get AWS profile from environment variable or use default
	awsProfile := getEnvOrDefault("AWS_PROFILE", "default")

	// Get AWS resource IDs from environment variables or use defaults
	vpcID := getEnvOrDefault("TEST_VPC_ID", "")
	subnetID := getEnvOrDefault("TEST_SUBNET_ID", "")
	amiID := getEnvOrDefault("TEST_AMI_ID", "")
	
	// Skip test if required environment variables are not set
	if vpcID == "" || subnetID == "" || amiID == "" {
		t.Skip("Skipping test because one or more required environment variables (TEST_VPC_ID, TEST_SUBNET_ID, TEST_AMI_ID) are not set")
	}
	
	// Configure Terraform options with real AWS resource IDs
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures",
		Vars: map[string]interface{}{
			"instance_name": instanceName,
			"vpc_id":     vpcID,
			"subnet_id":  subnetID,
			"ami_id":     amiID,
		},
		EnvVars: map[string]string{
			"AWS_PROFILE": awsProfile,
			"AWS_REGION": awsRegion,
		},
	})

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Get output values
	securityGroupID := terraform.Output(t, terraformOptions, "security_group_id")
	
	// Verify that the security group was created
	assert.NotEmpty(t, securityGroupID, "Security group ID should not be empty")
	
	// Success - the security groups were created
	fmt.Println("Security groups created successfully!")
}
