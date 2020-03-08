provider "aws" {
  region  = "us-east-2"
  profile = "terraform"
}

/* VPC */
resource "aws_vpc" "nube1" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "nube1"
  }

}

/* Internet Gateway */
resource "aws_internet_gateway" "nube1-gw" {
  vpc_id = "${aws_vpc.nube1.id}"

  tags = {
    Name = "main"
  }
}

/* Public Route Table */
resource "aws_route_table" "nube1-public-rt" {
  vpc_id = "${aws_vpc.nube1.id}"

  /* Route traffic to IGW */
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.nube1-gw.id}"
  }

  tags = {
    Name = "nube1-public-rt"
  }

}


/* Public Subnets */
resource "aws_subnet" "public-subnet" {
  count                   = "2"
  vpc_id                  = "${aws_vpc.nube1.id}"
  cidr_block              = "${var.subnet_cidr["${count.index + 1}"]}"
  availability_zone       = "${var.availability_zones["${count.index + 1}"]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
    Type = "public"
  }
}

/* Route Table Association */
resource "aws_route_table_association" "association" {
  count          = "${var.subnet_count}"
  subnet_id      = "${aws_subnet.public-subnet[count.index].id}"
  route_table_id = "${aws_route_table.nube1-public-rt.id}"

}

/* Security Groups */
resource "aws_security_group" "tf-allow_http" {
  name        = "allow_http"
  description = "allow http traffic"
  vpc_id      = "${aws_vpc.nube1.id}"

  /* Allow SSH */
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /* Allow HTTP */
  ingress {
    description = "open http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "open http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Open HTTP"
  }
}

/* EC2 instance */
resource "aws_instance" "web-servers" {
  count = "${var.instance_count}"
  ami                         = "ami-be7753db"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.tf-allow_http.id}"]
  subnet_id                   = "${aws_subnet.public-subnet[count.index].id}"
  associate_public_ip_address = true

  tags = {
    Name = "tf-web"
  }
}

/* Application Load Balancer */

/* Simple Storage Service Bucket */

/* IAM Role */