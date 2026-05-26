# Update the variables according to your requirement!

variable "project_name" {
  description = "Project Name - will prefix all generated AWS resource names"
  default     = "tgwlab"
}

variable "region" {
  description = "AWS region to deploy the lab into"
  default     = "ap-southeast-1"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

variable "edge_sg_vpc_cidr" {
  description = "Edge VPC CIDR"
  default     = "10.7.0.0/16"
}

variable "spoke_1_sg_vpc_cidr" {
  description = "Spoke VPC 1 CIDR"
  default     = "10.10.0.0/16"
}

variable "spoke_2_sg_vpc_cidr" {
  description = "Spoke VPC 2 CIDR"
  default     = "10.20.0.0/16"
}

variable "key_name" {
  description = "SSH Key Pair name that already exists in the target region"
  default     = "yourkey"
}

# Look up the latest Ubuntu 22.04 LTS (Jammy) AMI dynamically.
# This replaces the previously hard-coded AMI ID, which has since aged out.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
