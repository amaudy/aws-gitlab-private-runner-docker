import os
import pytest
import subprocess

# Define the path to the test Terraform files
TEST_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "unit")

@pytest.fixture(scope="session")
def aws_profile():
    """Return the AWS profile to use for testing."""
    return "devops-toryordonline"

@pytest.fixture(autouse=True, scope="session")
def setup_terraform_environment():
    """Set up the Terraform environment before running tests."""
    # Set AWS profile environment variable
    os.environ["AWS_PROFILE"] = "devops-toryordonline"
    
    # Initialize Terraform in the test directory if not already initialized
    if not os.path.exists(os.path.join(TEST_DIR, ".terraform")):
        subprocess.run(
            "terraform init",
            cwd=TEST_DIR,
            shell=True,
            check=True
        )
    
    yield
    
    # No cleanup needed for validation tests
