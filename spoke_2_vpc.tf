# VPC 2
resource "aws_vpc" "spoke_2_sg_vpc" {
  cidr_block = var.spoke_2_sg_vpc_cidr
  tags = {
    Name = "Spoke_SG_VPC_2"
  }
}

# Spoke 1 Private Subnet 1A
resource "aws_subnet" "spoke_2_prv_subnet_1a" {
  vpc_id                  = aws_vpc.spoke_2_sg_vpc.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"
  tags = {
    Name = "spoke_2_VPC_Prv_Subnet_1A"
  }
}

# Spoke 1 Public Subnet 1C
resource "aws_subnet" "spoke_2_prv_subnet_1c" {
  vpc_id                  = aws_vpc.spoke_2_sg_vpc.id
  cidr_block              = "10.20.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}c"
  tags = {
    Name = "spoke_2_VPC_Prv_Subnet_1C"
  }
}

# Attach  TGW to Spoke 1
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_spoke2" {
  subnet_ids         = [aws_subnet.spoke_2_prv_subnet_1a.id, aws_subnet.spoke_2_prv_subnet_1c.id ]
  transit_gateway_id = aws_ec2_transit_gateway.demo_tgw.id
  vpc_id             = aws_vpc.spoke_2_sg_vpc.id
}


# Create Internal Route Table
resource "aws_route_table" "spoke_2_prv_rt" {
  vpc_id = aws_vpc.spoke_2_sg_vpc.id
}

resource "aws_route" "spoke2_internet_access" {
  route_table_id         = aws_route_table.spoke_2_prv_rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tgw.id
}

resource "aws_route" "vpc2_edge_tgw_access" {
  route_table_id         = aws_route_table.spoke_2_prv_rt.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tgw.id
  }

# Route Table Associations
resource "aws_route_table_association" "spoke_2_prv_sub_1a_association" {
  subnet_id      = aws_subnet.spoke_2_prv_subnet_1a.id
  route_table_id = aws_route_table.spoke_2_prv_rt.id
}

resource "aws_route_table_association" "spoke_2_prv_sub_1c_association" {
  subnet_id      = aws_subnet.spoke_2_prv_subnet_1c.id
  route_table_id = aws_route_table.spoke_2_prv_rt.id
}

