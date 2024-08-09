# provider "aws" {
#   region = "ap-south-1"  # Adjust the region as needed
# }

# Create a VPC
resource "aws_vpc" "my2_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Prod_VPC"
  }
}

# Create a subnet
resource "aws_subnet" "my2_subnet" {
  vpc_id                  = aws_vpc.my2_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "ap-south-1a"  # Adjust as needed
  map_public_ip_on_launch = true
  tags = {
    Name = "Prod_Subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my2_igw" {
  vpc_id = aws_vpc.my2_vpc.id
  tags = {
    Name = "Prod_igw"
  }
}

# Create a route table
resource "aws_route_table" "my2_route_table" {
  vpc_id = aws_vpc.my2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my2_igw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
  tags = {
    Name = "Prod_route_table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "my2_route_table_association" {
  subnet_id      = aws_subnet.my2_subnet.id
  route_table_id = aws_route_table.my2_route_table.id
}


# Create a security group
resource "aws_security_group" "my2_security_group" {
  vpc_id = aws_vpc.my2_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22  # Allow SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Prod_security_group"
  }
}

# Create an EC2 instance
resource "aws_instance" "my2_instance" {
  ami           = "ami-0ad21ae1d0696ad58"  # Example AMI ID, adjust as needed
  instance_type = "t2.micro"  # Adjust instance type as needed
  subnet_id     = aws_subnet.my2_subnet.id
  vpc_security_group_ids = [aws_security_group.my2_security_group.id]
  associate_public_ip_address = true
  
  tags = {
    Name = "Prod_instance"
  }
}


# Create a VPC Peering Connection
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.my_vpc.id
  peer_vpc_id   = aws_vpc.my2_vpc.id
  auto_accept   = false  # Set to true if you want the connection to be accepted automatically

  tags = {
    Name = "vpc_peering"
  }
}


# Accept the VPC Peering Connection
resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept = true
  tags = {
    Name = "vpc_peering_accepter"
  }
}



