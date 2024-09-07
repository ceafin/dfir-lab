locals {
  my_private_local_resolved_ips = [for ip in flatten([for record in data.dns_a_record_set.fqdn_records : record.addrs]) : "${ip}/32"]
}


data "dns_a_record_set" "fqdn_records" {
  for_each = toset(var.my_private_local_fqdns)
  host     = each.value
}


# DFIR Lab VPC
resource "aws_vpc" "dfir_vpc" {
  cidr_block = "10.86.0.0/16"
  tags       = merge(local.default_tags, { Name = "DFIR Lab VPC" })
}

# Subnet for SIFT Workstation
resource "aws_subnet" "sift_subnet" {
  vpc_id     = aws_vpc.dfir_vpc.id
  cidr_block = "10.86.1.0/24"
  tags       = merge(local.default_tags, { Name = "DFIR SIFT Subnet" })
}

# Subnet for Windows Server
resource "aws_subnet" "windows_subnet" {
  vpc_id     = aws_vpc.dfir_vpc.id
  cidr_block = "10.86.2.0/24"
  tags       = merge(local.default_tags, { Name = "DFIR Windows Subnet" })
}

# Security Group
resource "aws_security_group" "dfir_sg" {
  vpc_id = aws_vpc.dfir_vpc.id

  # Allow SSH from My IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.my_private_local_resolved_ips
  }

  # Allow RDP from My IP address
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.my_private_local_resolved_ips
  }

  # Allow ICMP (Ping) from My IP address
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = local.my_private_local_resolved_ips
  }

  # Allow all TCP traffic within the VPC's CIDR range
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dfir_vpc.cidr_block] # Allow all TCP traffic within the VPC
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags, { Name = "DFIR Security Group" })
}

