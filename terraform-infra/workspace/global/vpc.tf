resource "aws_vpc" "main_vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform VPC"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
      Name = "Terraform Internet Gateway"
    }
}

resource "aws_subnet" "main_subnet" {
    count = 6
    vpc_id = aws_vpc.main_vpc.id
    map_public_ip_on_launch = true
    cidr_block = element(var.subnets_cidr, count.index)
    availability_zone = element(var.availability_zones, count.index)
    tags = {
      Name = "Terraform Subnet"
    }
}

resource "aws_route_table" "main_route_table" {
    vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
    tags = {   
      Name = "Terraform Route Table"
    }
}

resource "aws_route_table_association" "aws_route_table_association" {
    count = length(aws_subnet.main_subnet.*.id)
    subnet_id = element(aws_subnet.main_subnet.*.id, count.index)
    route_table_id = aws_route_table.main_route_table.id 
}

resource "aws_vpc_dhcp_options" "main_dhcp_options" {
  domain_name          = "ec2.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]
  netbios_name_servers = []
  ntp_servers          = []
  tags = {
    Name = "Terraform DHCP Options"
  }
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = aws_subnet.main_subnet[*].id
}