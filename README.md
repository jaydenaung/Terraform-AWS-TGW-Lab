# Terraform Lab - Automating AWS Transit Gateway 

It is definitely fun to design and build network on AWS. However,it is more fun when you automate it. 

In this tutorial, I'll do a step-by-step walk-through of automating an AWS environment which consists of three VPCs, and a Transit Gateway, using Terraform.

The lab environment on AWS will consist of the the following VPCs.

1. Edge VPC - A NAT instance (linux firewall), and a web server will be deployed into this VPC.

2. Spoke VPC 1 - A private web server instance will be deployed into this VPC.

3. Spoke VPC 2 - A private web server instance will be deployed into this VPC.

All three web servers are deployed into private subnets and not directly exposed to the Internet. They are exposed to the Internet via the NAT instance (linux router).


![header image](img/aws_tgw_linux_fw.png)

# Prerequisites

1. AWS Account (and key pair)
2. Terraform installed on your laptop. [Follow this guide on Terraform website.](https://www.terraform.io/downloads.html)
3. [Git](https://git-scm.com/downloads)

# Steps

## 1. Clone the git repo
```bash
git clone https://github.com/jaydenaung/Terraform-AWS-TGW-Lab
```

This will clone my git repo to your local directory.

## 2. Update variables

In the cloned repo directory:

- Edit [variables.tf](variables.tf) and update the values accordingly.

For example, change "yourkey" with your AWS SSH key pair that you should have created on AWS beforehand. 

```bash
variable "key_name" {
  description = "SSH Key Pair"
  default = "yourkey"
}
```

## 3. Execute the following commands

In the cloned repo directory: 

Execute the following and check everything is in order.

```bash
terraform plan
```
If you're ok with the plan and it doesn't show any error, you can apply.

```bash
echo yes | terraform apply
```
You will see the output from Terraform similar to the excerpt below:

```bash
...
aws_instance.web1: Still creating... [10s elapsed]
aws_instance.spoke2_web1: Still creating... [20s elapsed]
aws_instance.spoke1_web1: Still creating... [20s elapsed]
aws_instance.web1: Still creating... [20s elapsed]
aws_instance.vpc_edge_nat: Still creating... [20s elapsed]
aws_instance.spoke1_web1: Creation complete after 22s [id=i-05c0b63e20aa18d20]
aws_instance.vpc_edge_nat: Still creating... [30s elapsed]
aws_instance.web1: Still creating... [30s elapsed]
aws_instance.spoke2_web1: Still creating... [30s elapsed]
aws_instance.spoke2_web1: Creation complete after 32s [id=i-067daf534402246aa]
aws_instance.web1: Creation complete after 32s [id=i-0c8ff000033bcbfd8]
aws_instance.vpc_edge_nat: Still creating... [40s elapsed]
aws_instance.vpc_edge_nat: Creation complete after 42s [id=i-07189773c0ec04805]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

NAT_public_ip = 13.213.211.210

```
Once you see the output, the terraform automation has been compeleted.

## 4. Observe Your AWS environment (Once Terraform is complete)

If you take a look at your AWS environment at this point, you'll notice that the following AWS resources have been created by Terraform automatically (Look at the AWS network diagram). 

1. VPCs
2. Subnets
3. Route tables and respective routes
4. Transit Gateway and attachments
5. Transit Gateway route table
6. EIP
7. A NAT Instance and an internal web server in Edge VPC
8. Web servers in spoke VPC 1 and spoke VPC 2
9. Security Groups
10. Internet gateway (IGW)

>> You will also notice that all VPCS are connected to each other via the transit gateway, and all traffic (east-west and north-south) between VPCs wiill be routed via the NAT instance (linux firewall).

# 5. Access web servers in VPCs

From the previous state, take note of the NAT instance's public IP  - **"NAT_public_ip"**. For me, it's ***13.213.211.210***. It'll be different in your case.

The NAT instance is pre-configured so that all web servers sitting on internal subnets are exposed to the Internet via NAT instance's elastic IP (Public IP).

## Access Web server in Edge VPC
NAT instance is listening on port 80, and configured to NAT (forward) the traffic on port 80 to the web server in the ***edge VPC***. To access the website, go to your browser, and access to the NAT instance's public IP on port 80.

```
http://13.213.211.210 
```

You should be able to access the website hosted on the webserver (IP: 10.5.7.20) which is on the private subnet of the Edge VPC.

![header image](img/edge.png)


## Access Web server in Spoke VPC 1

NAT instance is listening on port 8081, and configured to NAT (forward) the traffic on port 8081 to the web server in the ***spoke VPC 1***. To access the website, go to your browser, and access to the NAT instance's public IP on port 8081.

```
http://13.213.211.210:8081 
```

You should see the website hosted on the webserver (Internal IP: 10.10.1.20) which is on the private subnet of the ***Spoke VPC 1***. Take note that the internal web server in spoke VPC is exposed via the NAT instance in edge VPC.

![header image](img/spoke1.png)

## Access Web server in Spoke VPC 2

NAT instance is listening on port 8082, and configured to NAT (forward) the traffic on port 8082 to the web server in the ***spoke VPC 2***. To access the website, go to your browser, and access to the NAT instance's public IP on port 8082.

```
http://13.213.211.210:8082
```

You should see the website hosted on the webserver (Internal IP: 10.20.1.20) which is on the private subnet of the ***Spoke VPC 2***. Take note that the internal web server in spoke VPC is exposed via the NAT instance in edge VPC.

![header image](img/spoke2.png)

>> Note: All Photos shown on the websites were taken by me, using an iPhone. They are photos of one of my most favorite cities on earth - **Edinburgh**!

# Additional East-West Traffic Test
If you're feeling adventurous, you can do the following test, besides accessing the websites on different VPCs. The NAT instance (linux firewall) is pre-configured so that all traffic between VPCs (east-west traffic) goes through it.

We can test the east-west traffic by accessing to an internal web server from an internal webserver.

1. Log in to the NAT Instance via SSH, using the key pair you've described in the variables.tf. 

2. Using the same key pair, jump to the web server in the Edge VPC.

```
ssh web1 -i yourkey
```
3. From the Web server in Edge VPC, try to SSH to any web server sitting in either spoke-1 or spoke-2 via their ***internal ip***.

```
ssh 10.20.1.10 -i yourkey
```

SSH traffic should be routed via the NAT instance, and you should be able to SSH to any of the internal web server from any internal instance in this lab.

# Clean-up
Once you're satisfied with your tests, and have finished enjoying my photos of Edinburgh, you can clean up the whole lab environment by simply executing the following command.

```bash
echo yes | terraform destroy
```

Happy Terraform-ing!



