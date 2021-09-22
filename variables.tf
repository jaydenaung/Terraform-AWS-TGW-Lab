# Update the variables according to your requirement!

variable "project_name" {
  description = "Project Name - will prefex all generated AWS resource names"
  default     = "tgwlab"
}
provider "aws" {
  profile = "default"
  region  = var.region
  version = "~> 3.59.0"
}

variable "region" {
  default = "ap-southeast-1"
}
data "aws_availability_zones" "azs" {
}

variable "edge_sg_vpc_cidr" {
  description = "Edge VPC CIDR"
  default = "10.7.0.0/16"
}

variable "spoke_1_sg_vpc_cidr" {
  description = "Spoke VPC 1 CIDR"
  default = "10.10.0.0/16"
}

variable "spoke_2_sg_vpc_cidr" {
  description = "Spoke VPC 2 CIDR"
  default = "10.20.0.0/16"
}

variable "key_name" {
  description = "SSH Key Pair"
  default = "yourkey"
}

variable "ubuntu_20_ami_sg" {
  description = "Ubuntu AMI ID (Singapore)"
  default = "ami-0d058fe428540cd89"
}


