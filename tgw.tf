#Create TGW
resource "aws_ec2_transit_gateway" "demo_tgw" {
  description = "demo_tgw"
  tags = {
    Name = "Demo_Transit_Gateway"
  }
}

resource "aws_ec2_transit_gateway_route_table" "association_default_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.demo_tgw.id
}

# TGW Route Table
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_edge.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.demo_tgw.association_default_route_table_id
}