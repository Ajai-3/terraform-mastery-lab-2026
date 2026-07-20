output "primary_ec2_public_ip" {
  description = "Public IP of Primary EC2"
  value       = aws_instance.primary_instance.public_ip
}

output "secondary_ec2_public_ip" {
  description = "Public IP of Secondary EC2"
  value       = aws_instance.secondary_instance.public_ip
}

output "primary_ec2_private_ip" {
  description = "Private IP of Primary EC2"
  value       = aws_instance.primary_instance.private_ip
}

output "secondary_ec2_private_ip" {
  description = "Private IP of Secondary EC2"
  value       = aws_instance.secondary_instance.private_ip
}