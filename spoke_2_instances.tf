# Web Server Security Group
resource "aws_security_group" "spoke_2_web_sg" {
  name        = "spoke_2_web_sg"
  description = "spoke_2_web_sg"
  vpc_id      = aws_vpc.spoke_2_sg_vpc.id

  # HTTP/S and SSH from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Ubuntu Instance on a private subnet
resource "aws_instance" "spoke2_web1" {
  ami                         = var.ubuntu_20_ami_sg
  instance_type               = "t2.nano"
  private_ip                  = "10.20.1.20"
  subnet_id                   = aws_subnet.spoke_2_prv_subnet_1a.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.spoke_2_web_sg.id]
  associate_public_ip_address = false
  user_data                   = file("spoke_2_userdata_web.sh")
  tags = {
    Name = "spoke_2_Web_Server_1"
  }
}

