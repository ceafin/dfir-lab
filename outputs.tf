# outputs.tf
#


output "local_fqdns" {
  value       = var.my_private_local_fqdns
  description = "The list of FQDN addresses."
}

output "local_resolved_ips" {
  value       = local.my_private_local_resolved_ips
  description = "The list of resolved IP addresses for the provided FQDNs."
}

# Output the public IPs of the instances
output "sift_public_ip" {
  value = aws_instance.sift_workstation.public_ip
}

output "victim_winserver_public_ip" {
  value = aws_instance.victim_winserver.public_ip
}

# Output the location of the generated PEM file
output "key_pem_file" {
  value = local_file.local_pem.filename
}
