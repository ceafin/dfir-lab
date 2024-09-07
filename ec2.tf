locals {

}

# Generate a new key pair or use an existing one
resource "tls_private_key" "dfir_lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dfir_key_pair" {
  key_name   = "dfir_key"
  public_key = tls_private_key.dfir_lab_key.public_key_openssh
}

# Output the private key to a PEM file (on local machine)
resource "local_file" "local_pem" {
  filename        = "${path.module}/dfir_key.pem"
  content         = tls_private_key.dfir_lab_key.private_key_pem
  file_permission = "0400"
}


# EC2 Instance for SIFT
resource "aws_instance" "sift_workstation" {
  ami                         = "ami-033658932fa06b1e6" # SIFT AMI ami-033658932fa06b1e6
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.sift_subnet.id
  security_groups             = [aws_security_group.dfir_sg.id]
  associate_public_ip_address = true                                # Assign a public IP
  key_name                    = aws_key_pair.dfir_key_pair.key_name # Use the generated key pair

  tags = merge(local.default_tags, { Name = "SIFT Workstation" })
}

# EC2 Instance for Windows "Victim" Server
resource "aws_instance" "victim_winserver" {
  ami                         = "ami-0b2b340fdd56e13ce" # Windows Server 2016 Base AMI
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.windows_subnet.id
  security_groups             = [aws_security_group.dfir_sg.id]
  associate_public_ip_address = true                                # Assign a public IP
  key_name                    = aws_key_pair.dfir_key_pair.key_name # Use the generated key pair

  tags = merge(local.default_tags, { Name = "Victim Workstation" })
}
