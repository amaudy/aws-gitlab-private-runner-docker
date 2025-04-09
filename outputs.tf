output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.gitlab_runner.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (if assigned)"
  value       = var.assign_public_ip ? aws_instance.gitlab_runner.public_ip : null
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.gitlab_runner.private_ip
}

output "security_group_id" {
  description = "ID of the security group created for the GitLab runner"
  value       = aws_security_group.gitlab_runner.id
}

output "iam_role_name" {
  description = "Name of the IAM role created for the GitLab runner"
  value       = aws_iam_role.gitlab_runner_role.name
}