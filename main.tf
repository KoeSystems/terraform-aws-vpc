################################################################################
# DATA
################################################################################
data "aws_availability_zones" "available" {}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "mod" {
  cidr_block                       = "${var.cidr_block}"
  instance_tenancy                 = "${var.tenancy}"
  enable_dns_support               = "${var.enable_dns_support}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_classiclink               = false
  assign_generated_ipv6_cidr_block = "${var.ipv6_cidr_block}"

  tags {
    Name = "${var.name}"
  }
}

################################################################################
# DHCP Options
################################################################################
resource "aws_vpc_dhcp_options" "mod" {
  domain_name         = "${var.domain_name}"
  domain_name_servers = "${var.domain_name_servers}"
  
  tags {
    Name = "${var.name}"
  }
}

resource "aws_vpc_dhcp_options_association" "mod" {
  vpc_id          = "${aws_vpc.mod.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.mod.id}"
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"

  tags {
    Name = "${var.name}"
  }
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_eip" "mod" {
  vpc  = true
  count = "${var.AZs}"
}

resource "aws_nat_gateway" "mod" {
  allocation_id = "${element(aws_eip.mod.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${var.AZs}"
}

################################################################################
# Subnets
################################################################################
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.mod.cidr_block, 8, 30 + count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${var.AZs}"

  tags {
    Name = "public-${substr(element(sort(data.aws_availability_zones.available.names), count.index),9,1)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.mod.cidr_block, 8, 40 + count.index)}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${var.AZs}"

  tags {
    Name = "private-${substr(element(sort(data.aws_availability_zones.available.names), count.index),9,1)}"
  }
}

################################################################################
# Routing Tables
################################################################################
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${var.AZs}"
  
  tags {
    Name = "public-${substr(element(data.aws_availability_zones.available.names, count.index),9,1)}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  count          = "${var.AZs}"
}

resource "aws_route" "public" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
  count                  = "${var.AZs}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${var.AZs}"
  
  tags {
    Name = "private-${substr(element(data.aws_availability_zones.available.names, count.index),9,1)}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${var.AZs}"
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.mod.*.id, count.index)}"
  count                  = "${var.AZs}"
}

################################################################################
# Network ACL
################################################################################
resource "aws_network_acl" "public" {
  vpc_id     = "${aws_vpc.mod.id}"
  subnet_ids = [ "${aws_subnet.public.*.id}" ]

  tags {
    Name = "public"
  }
}

resource "aws_network_acl_rule" "public_ingress" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "private" {
  vpc_id     = "${aws_vpc.mod.id}"
  subnet_ids = [ "${aws_subnet.private.*.id}" ]

  tags {
    Name = "private"
  }
}

resource "aws_network_acl_rule" "private_ingress" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_egress" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}