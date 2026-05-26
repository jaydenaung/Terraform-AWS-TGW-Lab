resource "aws_vpc" "edge_sg_vpc" {
  cidr_block = var.edge_sg_vpc_cidr
  tags = {
    Name = "Edge VPC"
  }
}

# Create an IGW 
resource "aws_internet_gateway" "edge_vpc_igw" {
  vpc_id = aws_vpc.edge_sg_vpc.id
}


# Define a NAT subnet primary availability zone
resource "aws_subnet" "edge_external_subnet_1a" {
  vpc_id                  = aws_vpc.edge_sg_vpc.id
  cidr_block              = "10.7.0.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  tags = {
    Name = "Edge_VPC_External_Subnet_1A"
  }
}

# Define a NAT subnet primary availability zone
resource "aws_subnet" "edge_internal_subnet_1a" {
  vpc_id                  = aws_vpc.edge_sg_vpc.id
  cidr_block              = "10.7.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  tags = {
    Name = "Edge_VPC_Internal_Subnet_1A"
  }
}

# Define a Web server Internal subnet
resource "aws_subnet" "edge_web_subnet_1a" {
  vpc_id                  = aws_vpc.edge_sg_vpc.id
  cidr_block              = "10.7.5.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  tags = {
    Name = "Edge_VPC_Web_Subnet_1A"
  }
}

# Attach  TGW to Edge VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_edge" {
  subnet_ids         = [aws_subnet.edge_internal_subnet_1a.id]
  transit_gateway_id = aws_ec2_transit_gateway.demo_tgw.id
  vpc_id             = aws_vpc.edge_sg_vpc.id
}

# Create a Public route table

resource "aws_route_table" "edge_pub_rt" {
  vpc_id = aws_vpc.edge_sg_vpc.id

  # Route to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.edge_vpc_igw.id
  }
  tags = {
    Name = "Edge_VPC_Public_Route_Table"
  }
}

resource "aws_route_table_association" "edge_rt_associatio_1a" {
  subnet_id      = aws_subnet.edge_external_subnet_1a.id
  route_table_id = aws_route_table.edge_pub_rt.id
}

# Create Internal Route Table
resource "aws_route_table" "edge_internal_rt" {
  vpc_id = aws_vpc.edge_sg_vpc.id
}

# Create Default route
resource "aws_route" "defaultroute" {
  route_table_id         = aws_route_table.edge_internal_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_nic2.id
  #instance_id = aws_instance.vpc_edge_web1.id
}

resource "aws_route_table_association" "nat_internal_association" {
  subnet_id      = aws_subnet.edge_internal_subnet_1a.id
  route_table_id = aws_route_table.edge_internal_rt.id
}

resource "aws_route_table_association" "web_sub_association" {
  subnet_id      = aws_subnet.edge_web_subnet_1a.id
  route_table_id = aws_route_table.edge_internal_rt.id
}

resource "aws_route" "edge_vpcroutes" {
  route_table_id         = aws_route_table.edge_internal_rt.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tgw.id
}
