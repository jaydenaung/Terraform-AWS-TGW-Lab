# Output the public ip of the gateway
output "NAT_public_ip" {
  value = aws_eip.NAT_EIP.public_ip
}