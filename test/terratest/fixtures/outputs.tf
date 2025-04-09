output "instance_id" {
  description = "The ID of the GitLab runner instance"
  value       = module.gitlab_runner.instance_id
}

output "instance_public_ip" {
  description = "The public IP of the GitLab runner instance"
  value       = module.gitlab_runner.instance_public_ip
}

output "security_group_id" {
  description = "The ID of the security group attached to the GitLab runner instance"
  value       = module.gitlab_runner.security_group_id
}

output "iam_role_name" {
  description = "The name of the IAM role attached to the GitLab runner instance"
  value       = module.gitlab_runner.iam_role_name
}
