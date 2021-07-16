# Very Permissive Security Group
resource "aws_security_group" "edge_vpc_permissive_sg" {
  name        = "edge_vpc_permissive_sg"
  description = "edge_vpc_permissive_sg"
  vpc_id      = aws_vpc.edge_sg_vpc.id

  # access from the internet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "nat_nic1" {
  subnet_id         = aws_subnet.edge_external_subnet_1a.id
  private_ips       = ["10.7.0.10"]
  security_groups   = [aws_security_group.edge_vpc_permissive_sg.id]
  source_dest_check = false
  tags = {
    Name = "external_network_interface"
  }
}

resource "aws_network_interface" "nat_nic2" {
  subnet_id         = aws_subnet.edge_internal_subnet_1a.id
  private_ips       = ["10.7.1.10"]
  security_groups   = [aws_security_group.edge_vpc_permissive_sg.id]
  source_dest_check = false
  tags = {
    Name = "internal_network_interface"
  }
}

# Create Ubuntu  NAT Instance (Linux Firewall) to route north-south and east-west traffic 
resource "aws_instance" "vpc_edge_nat" {
  ami           = var.ubuntu_20_ami_sg
  instance_type = "t2.micro"
  key_name      = var.key_name
  user_data     = file("userdata-natgateway.sh")
  tags = {
    Name = "vpc_edge_NAT_Instance"
  }
  network_interface {
    network_interface_id = aws_network_interface.nat_nic1.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.nat_nic2.id
    device_index         = 1
  }
}

resource "aws_eip" "NAT_EIP" {
  network_interface = aws_network_interface.nat_nic1.id
  vpc               = true
  depends_on        = [aws_internet_gateway.edge_vpc_igw]
}


# Very Permissive Security Group
resource "aws_security_group" "edge_web_sg" {
  name        = "edge_web_sg"
  description = "edge_web_sg"
  vpc_id      = aws_vpc.edge_sg_vpc.id

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
    security_groups = ["${aws_security_group.edge_vpc_permissive_sg.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Ubuntu web server on private subnet
resource "aws_instance" "web1" {
  ami                         = var.ubuntu_20_ami_sg
  instance_type               = "t2.nano"
  private_ip                  = "10.7.5.20"
  subnet_id                   = aws_subnet.edge_web_subnet_1a.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.edge_web_sg.id]
  associate_public_ip_address = false
  user_data                   = file("userdata-web.sh")
  tags = {
    Name = "Edge_VPC_Web_Server_1"
  }
}

