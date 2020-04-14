resource "aws_vpc" "c_vpc" {
cidr_block = "10.0.0.0/16"
    tags = {
        name = "cloudvpc"
    }
}
resource "aws_subnet" "sub1" {
    vpc_id = "${aws_vpc.c_vpc.id}"
    cidr_block = "10.0.0.0/24"
    tags = {
        name = "subnet1"
    }
}
resource "aws_subnet" "sub2" {
    vpc_id = "${aws_vpc.c_vpc.id}"
    cidr_block = "10.0.1.0/24"
    tags ={
        name = "pub_subnet2"
    }
}
resource "aws_subnet" "sub3" {
    vpc_id = "${aws_vpc.c_vpc.id}"
    cidr_block = "10.0.2.0/24"
    tags ={
        name = "private_subnet1"
    }
}
resource "aws_subnet" "sub4" {
    vpc_id = "${aws_vpc.c_vpc.id}"
    cidr_block = "10.0.3.0/24"
    tags = {
        name = "private_subnet2"
    } 
}
resource "aws_route_table" "rt1" {
  vpc_id = "${aws_vpc.c_vpc.id}"
  
}
resource "aws_route_table_association" "b" {
  gateway_id     = "${aws_internet_gateway.igw.id}"
  route_table_id = "${aws_route_table.rt1.id}"
}

resource "aws_route_table" "rt2" {
  vpc_id = "${aws_vpc.c_vpc.id}"
}
resource "aws_route_table_association" "rta1" {
  subnet_id      = "${aws_subnet.sub1.id}"
  route_table_id = "${aws_route_table.rt1.id}"
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = "${aws_subnet.sub3.id}"
  route_table_id = "${aws_route_table.rt2.id}"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.c_vpc.id}"
  tags = {
      name = "igw"
  }
}
resource "aws_egress_only_internet_gateway" "egress" {
  vpc_id = "${aws_vpc.c_vpc.id}"
}
resource "aws_route" "route" {
  route_table_id              = "8206c923-0d14-46eb-88c7-973f076afbf5"
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = "${aws_egress_only_internet_gateway.egress.id}"
}
resource "aws_network_interface" "multi-ip" {
  subnet_id   = "${aws_subnet.sub3.id}"
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = "${aws_network_interface.multi-ip.id}"
}

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = "${aws_network_interface.multi-ip.id}"
}
resource "aws_nat_gateway" "nw" {
  allocation_id = "${aws_eip.one.id}"
  allocation_id = "${aws_eip.two.id}"
  subnet_id     = "${aws_subnet.sub3.id}"
  subnet_id    = "${aws_subnet.sub4.id}"
  tags = {
    Name = "gw NAT"
  }
}

