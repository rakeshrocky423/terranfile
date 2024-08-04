# Configure the AWS provider
provider "aws" {
    region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "terran_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "terran-vpc"
    }
}

# Create a Subnet
resource "aws_subnet" "terran_subnet" {
    vpc_id                  = aws_vpc.terran_vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "ap-south-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "terran-subnet"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "terran_igw" {
    vpc_id = aws_vpc.terran_vpc.id
    tags = {
        Name = "terran-igw"
    }
}

# Create a Route Table
resource "aws_route_table" "terran_rt" {
    vpc_id = aws_vpc.terran_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.terran_igw.id
    }
    tags = {
        Name = "terran-rt"
    }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "terran_rt_association" {
    subnet_id      = aws_subnet.terran_subnet.id
    route_table_id = aws_route_table.terran_rt.id
}

# Create a Security Group
resource "aws_security_group" "terran_sg" {
    description = "Allow SSH traffic"
    vpc_id      = aws_vpc.terran_vpc.id

    ingress {
        description = "Allow SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "terran-sg"
    }
}

# Create an EC2 Instance
resource "aws_instance" "terran_instance" {
    subnet_id       = aws_subnet.terran_subnet.id
    ami             = "ami-0ad21ae1d0696ad58"
    instance_type   = "t2.micro"
    key_name        = "terraform"
    security_groups  = [aws_security_group.terran_sg.id]  # Use security_group_ids instead of security_group_id

    tags = {
        Name = "terraform-instance"
    }
}
