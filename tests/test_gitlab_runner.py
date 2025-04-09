import os
import subprocess
import pytest
import re

# Path to the test directory
TEST_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "unit")

def run_command(command, cwd=None):
    """Run a shell command and return the output."""
    result = subprocess.run(
        command,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
        text=True
    )
    return result

def test_terraform_validate():
    """Test that the Terraform configuration is valid."""
    # Run terraform validate with no color output
    result = run_command("terraform validate -no-color", cwd=TEST_DIR)
    
    # Check that the command was successful
    assert result.returncode == 0, f"Terraform validation failed: {result.stderr}"
    assert "Success! The configuration is valid." in result.stdout

def test_module_structure():
    """Test that the module structure is correct."""
    # Get the root module path
    root_module_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Check that required files exist
    required_files = ["main.tf", "outputs.tf", "versions.tf", "templates/user_data.sh"]
    for file in required_files:
        file_path = os.path.join(root_module_path, file)
        assert os.path.exists(file_path), f"Required file {file} not found"

def test_module_outputs():
    """Test that the module outputs are defined correctly."""
    # Get the root module path
    root_module_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Read the outputs.tf file
    with open(os.path.join(root_module_path, "outputs.tf"), "r") as f:
        outputs_content = f.read()
    
    # Check that required outputs are defined
    required_outputs = ["instance_id", "security_group_id", "instance_private_ip", "instance_public_ip"]
    for output in required_outputs:
        assert f'output "{output}"' in outputs_content, f"Required output {output} not defined"

def test_user_data_script():
    """Test that the user data script contains required configurations."""
    # Get the root module path
    root_module_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Read the user_data.sh file
    with open(os.path.join(root_module_path, "templates/user_data.sh"), "r") as f:
        user_data_content = f.read()
    
    # Check that required configurations are present
    assert "gitlab-runner register" in user_data_content, "GitLab runner registration command not found"
    assert "--executor \"docker\"" in user_data_content, "Docker executor configuration not found"
    assert "apt-get update" in user_data_content or "yum update" in user_data_content, "Package update command not found"
    assert "docker" in user_data_content, "Docker installation not found"

def test_main_tf_resources():
    """Test that the main.tf file contains required resources."""
    # Get the root module path
    root_module_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Read the main.tf file
    with open(os.path.join(root_module_path, "main.tf"), "r") as f:
        main_content = f.read()
    
    # Check that required resources are defined
    assert "resource \"aws_security_group\"" in main_content, "Security group resource not defined"
    assert "resource \"aws_iam_role\"" in main_content, "IAM role resource not defined"
    assert "resource \"aws_instance\"" in main_content, "EC2 instance resource not defined"
    
    # Check for security group configuration
    assert "egress {" in main_content, "Egress rule not defined in security group"
    assert "0.0.0.0/0" in main_content, "Egress rule allowing all outbound traffic not found"
    
    # Check for IAM role configuration
    assert "assume_role_policy" in main_content, "IAM role assume_role_policy not defined"
    assert "ec2.amazonaws.com" in main_content, "EC2 service principal not found in IAM role"
    
    # Check for instance configuration
    assert "user_data" in main_content, "user_data not defined in EC2 instance"
    assert "iam_instance_profile" in main_content, "iam_instance_profile not defined in EC2 instance"
