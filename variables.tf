variable "project_name" {
  description = "Project Name - will prefex all generated AWS resource names"
  default     = "tgwlab"
}
provider "aws" {
  profile = "default"
  region  = var.region
  version = "~> 2.61.0"
}

variable "region" {
  default = "ap-southeast-1"
}
data "aws_availability_zones" "azs" {
}
variable "edge_sg_vpc_cidr" {}
variable "spoke_1_sg_vpc_cidr" {}
variable "spoke_2_sg_vpc_cidr" {}
variable "key_name" {}
variable "ubuntu_20_ami_sg" {}

