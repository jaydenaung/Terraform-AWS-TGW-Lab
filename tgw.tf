# Create TGW. Default association + propagation are left enabled,
# so VPC attachments are auto-associated/propagated against the
# default route table that AWS creates for the TGW.
resource "aws_ec2_transit_gateway" "demo_tgw" {
  description = "demo_tgw"
  tags = {
    Name = "Demo_Transit_Gateway"
  }
}

# Default route on the TGW's default association route table:
# any traffic with no more-specific match is sent to the Edge VPC
# attachment, where the NAT instance handles north-south egress.
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_edge.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.demo_tgw.association_default_route_table_id
}
