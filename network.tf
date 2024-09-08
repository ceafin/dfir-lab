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

# Internet Gateway for VPC
resource "aws_internet_gateway" "dfir_igw" {
  vpc_id = aws_vpc.dfir_vpc.id
  tags   = merge(local.default_tags, { Name = "DFIR Lab Internet Gateway" })
}

# Route Table with the IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.dfir_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dfir_igw.id
  }

  tags = merge(local.default_tags, { Name = "DFIR Lab Public Route Table" })
}

# Subnet for SIFT Workstation
resource "aws_subnet" "sift_subnet" {
  vpc_id     = aws_vpc.dfir_vpc.id
  cidr_block = "10.86.1.0/24"
  tags       = merge(local.default_tags, { Name = "DFIR Lab SIFT Subnet" })
}

# Subnet for Windows Server
resource "aws_subnet" "windows_subnet" {
  vpc_id     = aws_vpc.dfir_vpc.id
  cidr_block = "10.86.2.0/24"
  tags       = merge(local.default_tags, { Name = "DFIR Lab Windows Subnet" })
}

# Associate the route table with the subnets to make them public
resource "aws_route_table_association" "sift_subnet_association" {
  subnet_id      = aws_subnet.sift_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "windows_subnet_association" {
  subnet_id      = aws_subnet.windows_subnet.id
  route_table_id = aws_route_table.public_route_table.id
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

  tags = merge(local.default_tags, { Name = "DFIR Lab Security Group" })
}

