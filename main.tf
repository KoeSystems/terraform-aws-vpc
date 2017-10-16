################################################################################
# Data
################################################################################
data "aws_availability_zones" "available" {}
data "aws_region" "current" { current = true }

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
  domain_name         = "${var.name}.${data.aws_region.current.name}.${var.domain_name}"
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
# Internet IPv6 Egress Gateway
################################################################################
resource "aws_egress_only_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${var.ipv6_private_egress ? 1 : 0}"
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_eip" "mod" {
  vpc   = true
  count = "${var.enable_nat_gw ? length(split(",",var.AZs)) : 0}"
}

resource "aws_nat_gateway" "mod" {
  allocation_id = "${element(aws_eip.mod.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${var.enable_nat_gw ? length(split(",",var.AZs)) : 0}"
}

################################################################################
# Subnets IPv4
################################################################################
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.mod.cidr_block, 8, 30 + count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 0 : 1) }"

  tags {
    Name = "${var.name}-public-${substr(element(sort(data.aws_availability_zones.available.names), count.index),-1,1)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.mod.cidr_block, 8, 40 + count.index)}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 0 : 1) }"

  tags {
    Name = "${var.name}-private-${substr(element(sort(data.aws_availability_zones.available.names), count.index),-1,1)}"
  }
}

################################################################################
# Subnets IPv6
################################################################################
resource "aws_subnet" "public_ipv6" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.mod.cidr_block, 8, 30 + count.index)}"
  ipv6_cidr_block         = "${var.ipv6_cidr_block ? cidrsubnet(aws_vpc.mod.ipv6_cidr_block, 8, 30 + count.index) : "" }"
  map_public_ip_on_launch = true
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 1 : 0) }"

  tags {
    Name = "${var.name}-public-${substr(element(sort(data.aws_availability_zones.available.names), count.index),-1,1)}"
  }
}

resource "aws_subnet" "private_ipv6" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.mod.cidr_block, 8, 40 + count.index)}"
  ipv6_cidr_block         = "${var.ipv6_cidr_block ? cidrsubnet(aws_vpc.mod.ipv6_cidr_block, 8, 40 + count.index) : "" }"
  map_public_ip_on_launch = false
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 1 : 0) }"

  tags {
    Name = "${var.name}-private-${substr(element(sort(data.aws_availability_zones.available.names), count.index),-1,1)}"
  }
}

################################################################################
# Routing Tables
################################################################################
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${ length(split(",",var.AZs)) }"
  
  tags {
    Name = "${var.name}-public-${substr(element(data.aws_availability_zones.available.names, count.index),-1,1)}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.mod.id}"
  count  = "${ length(split(",",var.AZs)) }"
  
  tags {
    Name = "${var.name}-private-${substr(element(data.aws_availability_zones.available.names, count.index),-1,1)}"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.mod.default_route_table_id}"
  tags {
    Name = "${var.name}-default-empty"
  }
}

################################################################################
# Routes IPv4
################################################################################
resource "aws_route_table_association" "public" {
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  count          = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 0 : 1) }"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 0 : 1) }"
}

resource "aws_route" "public" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
  count                  = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 0 : 1) }"
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.mod.*.id, count.index)}"
  count                  = "${(var.ipv6_cidr_block ? 0 : 1) * (var.enable_nat_gw ? length(split(",",var.AZs)) : 0)}"
}

################################################################################
# Routing Tables IPv6
################################################################################
resource "aws_route_table_association" "public_ipv6" {
  subnet_id      = "${element(aws_subnet.public_ipv6.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  count          = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 1 : 0) }"
}

resource "aws_route_table_association" "private_ipv6" {
  subnet_id      = "${element(aws_subnet.private_ipv6.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 1 : 0) }"
}

resource "aws_route" "public_ipv4" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
  count                  = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 1 : 0) }"
}

resource "aws_route" "public_ipv6" {
  route_table_id              = "${element(aws_route_table.public.*.id, count.index)}"
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = "${aws_internet_gateway.mod.id}"
  count                       = "${ length(split(",",var.AZs)) * (var.ipv6_cidr_block ? 1 : 0) }"
}

resource "aws_route" "private_ipv4" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.mod.*.id, count.index)}"
  count                  = "${(var.ipv6_cidr_block ? 1 : 0) * (var.enable_nat_gw ? length(split(",",var.AZs)) : 0)}"
}

resource "aws_route" "private_ipv6_egress" {
  route_table_id              = "${element(aws_route_table.private.*.id, count.index)}"
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = "${aws_egress_only_internet_gateway.mod.id}"
  count                       = "${ length(split(",",var.AZs)) * (var.ipv6_private_egress ? 1 : 0) }"
}

################################################################################
# Network ACL IPv4
################################################################################
resource "aws_network_acl" "public" {
  vpc_id     = "${aws_vpc.mod.id}"
  subnet_ids = [ "${aws_subnet.public.*.id}" ]
  count      = "${var.ipv6_cidr_block ? 0 : 1}"

  tags {
    Name = "${var.name}-public"
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
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 0 : 1)}"
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
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 0 : 1)}"
}

resource "aws_network_acl" "private" {
  vpc_id     = "${aws_vpc.mod.id}"
  subnet_ids = [ "${aws_subnet.private.*.id}" ]
  count      = "${var.ipv6_cidr_block ? 0 : 1}"

  tags {
    Name = "${var.name}-private"
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
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 0 : 1)}"
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
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 0 : 1)}"
}


################################################################################
# Network ACL IPv6
################################################################################
resource "aws_network_acl" "public_ipv6" {
  vpc_id     = "${aws_vpc.mod.id}"
  subnet_ids = [ "${aws_subnet.public_ipv6.*.id}" ]
  count      = "${var.ipv6_cidr_block ? 1 : 0}"

  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_network_acl_rule" "public_ingress_ipv4" {
  network_acl_id = "${aws_network_acl.public_ipv6.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0 )}"
}

resource "aws_network_acl_rule" "public_ingress_ipv6" {
  network_acl_id = "${aws_network_acl.public_ipv6.id}"
  rule_number     = 101
  egress          = false
  protocol        = "-1"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  count           = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0 )}"
}

resource "aws_network_acl_rule" "public_egress_ipv4" {
  network_acl_id = "${aws_network_acl.public_ipv6.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0 )}"
}

resource "aws_network_acl_rule" "public_egress_ipv6" {
  network_acl_id  = "${aws_network_acl.public_ipv6.id}"
  rule_number     = 101
  egress          = true
  protocol        = "-1"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  count           = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0 )}"
}

resource "aws_network_acl" "private_ipv6" {
  vpc_id     = "${aws_vpc.mod.id}"
  subnet_ids = [ "${aws_subnet.private_ipv6.*.id}" ]
  count      = "${var.ipv6_cidr_block ? 1 : 0}"

  tags {
    Name = "${var.name}-private"
  }
}

resource "aws_network_acl_rule" "private_ingress_ipv4" {
  network_acl_id = "${aws_network_acl.private_ipv6.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0)}"
}

resource "aws_network_acl_rule" "private_ingress_ipv6" {
  network_acl_id = "${aws_network_acl.private_ipv6.id}"
  rule_number     = 101
  egress          = false
  protocol        = "-1"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  count           = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0)}"
}

resource "aws_network_acl_rule" "private_egress_ipv4" {
  network_acl_id = "${aws_network_acl.private_ipv6.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  count          = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0)}"
}

resource "aws_network_acl_rule" "private_egress_ipv6" {
  network_acl_id  = "${aws_network_acl.private_ipv6.id}"
  rule_number     = 101
  egress          = true
  protocol        = "-1"
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  count           = "${var.allow_all_ACL * (var.ipv6_cidr_block ? 1 : 0)}"
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.mod.default_network_acl_id}"
  tags {
    Name = "${var.name}-default-deny-all"
  }
}

################################################################################
# Default Security Group
################################################################################
resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.mod.id}"
  tags {
    Name = "${var.name}-default-deny-all"
  }
}

################################################################################
# FLow Logs
################################################################################
resource "aws_cloudwatch_log_group" "vpc" {
  name              = "/aws/vpc/${var.name}-flow-logs"
  retention_in_days = 30
  count             = "${var.enable_vpc_flow_logs ? 1 : 0}"
}

resource "aws_iam_role" "flow_logs" {
  name               = "AmazonVPCFlowLogs"
  assume_role_policy = "${file("${path.module}/policies/vpc-flow-logs-assume-policy.json")}"
  count              = "${var.enable_vpc_flow_logs ? 1 : 0}"
}

resource "aws_iam_role_policy" "AmazonVPCFlowLogs" {
  name   = "AmazonVPCFlowLogs"
  role   = "${aws_iam_role.flow_logs.id}"
  policy = "${file("${path.module}/policies/vpc-flow-logs-policy.json")}"
  count  = "${var.enable_vpc_flow_logs ? 1 : 0}"
}

resource "aws_flow_log" "mod" {
  vpc_id         = "${aws_vpc.mod.id}"
  log_group_name = "${aws_cloudwatch_log_group.vpc.name}"
  iam_role_arn   = "${aws_iam_role.flow_logs.arn}"
  traffic_type   = "ALL"
  count          = "${var.enable_vpc_flow_logs ? 1 : 0}"
}

################################################################################
# Route53 Private Hosted Zone
################################################################################
resource "aws_route53_zone" "secondary_private" {
  comment = "Private zone for ${var.name} in ${data.aws_region.current.name} under ${var.domain_name}."
  name    = "${var.name}.${data.aws_region.current.name}.${var.domain_name}"
  vpc_id  = "${aws_vpc.mod.id}"
}

resource "aws_route53_zone" "secondary_public" {
  comment = "Public zone for ${var.name} in ${data.aws_region.current.name} under ${var.domain_name}."
  name    = "${var.name}.${data.aws_region.current.name}.${var.domain_name}"
}

resource "aws_route53_record" "NS" {
  zone_id = "${var.domain_ID}"
  name    = "${element(aws_route53_zone.secondary_public.*.name, 0)}"
  type    = "NS"
  ttl     = "30"
  records = [
    "${aws_route53_zone.secondary_public.name_servers.0}",
    "${aws_route53_zone.secondary_public.name_servers.1}",
    "${aws_route53_zone.secondary_public.name_servers.2}",
    "${aws_route53_zone.secondary_public.name_servers.3}"
  ]
  depends_on = [ "aws_route53_zone.secondary_public" ]
}