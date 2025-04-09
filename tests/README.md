# GitLab Runner Terraform Module Tests

This directory contains tests for the GitLab Runner Terraform module using pytest-terraform.

## Prerequisites

- Python 3.x
- Terraform 0.13+
- AWS credentials configured with the `devops-toryordonline` profile

## Setup

1. Activate the virtual environment:
   ```
   source venv/bin/activate
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

## Running Tests

To run all tests:
```
pytest
```

To run tests with verbose output:
```
pytest -v
```

## Test Structure

- `conftest.py`: Contains pytest fixtures for Terraform testing
- `test_gitlab_runner.py`: Contains tests for the GitLab runner module
- `unit/`: Contains Terraform configurations for unit testing

## Notes

- Tests are designed to validate the Terraform configuration without actually creating resources
- The test uses the AWS profile `devops-toryordonline` for authentication
