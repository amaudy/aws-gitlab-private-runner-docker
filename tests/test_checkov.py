import os
import subprocess
import pytest

# Get the root module path
ROOT_MODULE_PATH = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def run_checkov_scan(directory, output_file=None, framework="terraform"):
    """Run a Checkov scan on the specified directory."""
    cmd = ["checkov", "-d", directory, "--framework", framework]
    
    if output_file:
        cmd.extend(["--output", "json", "--output-file", output_file])
    
    # Run Checkov with soft fail to capture all issues
    cmd.append("--soft-fail")
    
    result = subprocess.run(
        cmd,
        cwd=ROOT_MODULE_PATH,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    return result

def test_checkov_scan_module():
    """Run Checkov scan on the main module and report findings."""
    # Create a directory for scan results if it doesn't exist
    scan_dir = os.path.join(ROOT_MODULE_PATH, "scan_results")
    os.makedirs(scan_dir, exist_ok=True)
    
    # Output file for the scan results
    output_file = os.path.join(scan_dir, "checkov_scan_results.json")
    
    # Run the scan
    result = run_checkov_scan(ROOT_MODULE_PATH, output_file)
    
    # Print the scan summary
    print("\nCheckov Scan Summary:")
    print(result.stdout)
    
    # Test passes even with security findings (informational test)
    # In a CI/CD pipeline, you might want to fail the test if there are high severity findings
    assert result.returncode == 0 or result.returncode == 1, f"Checkov scan failed with return code {result.returncode}"
    
    # Verify that the output file was created
    assert os.path.exists(output_file), "Checkov scan output file was not created"
    
    print(f"\nDetailed scan results saved to: {output_file}")

def test_checkov_scan_test_config():
    """Run Checkov scan on the test configuration and report findings."""
    # Path to the test configuration
    test_dir = os.path.join(ROOT_MODULE_PATH, "tests", "unit")
    
    # Create a directory for scan results if it doesn't exist
    scan_dir = os.path.join(ROOT_MODULE_PATH, "scan_results")
    os.makedirs(scan_dir, exist_ok=True)
    
    # Output file for the scan results
    output_file = os.path.join(scan_dir, "checkov_test_scan_results.json")
    
    # Run the scan
    result = run_checkov_scan(test_dir, output_file)
    
    # Print the scan summary
    print("\nCheckov Scan Summary for Test Configuration:")
    print(result.stdout)
    
    # Test passes even with security findings (informational test)
    assert result.returncode == 0 or result.returncode == 1, f"Checkov scan failed with return code {result.returncode}"
    
    # Verify that the output file was created
    assert os.path.exists(output_file), "Checkov scan output file was not created"
    
    print(f"\nDetailed scan results saved to: {output_file}")
