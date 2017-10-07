output "vpc_id"                     { value = "${aws_vpc.mod.id}"                                       description = "VPC unique ID." }
output "vpc_name"                   { value = "${var.name}"                                             description = "VPC name." }
output "ipv4_cidr_block"            { value = "${aws_vpc.mod.cidr_block}"                               description = "IPv4 assigned to the VPC." }
output "ipv6_cidr_block"            { value = "${aws_vpc.mod.ipv6_cidr_block }"                         description = "IPv6 assigned to the VPC." }
output "domain_name"                { value = "${var.domain_name}"                                      description = "Route53 internal hosted zone assigned to the VPC." }
output "nat_ids"                    { value = "${join(",", aws_nat_gateway.mod.*.id) }"                 description = "List of the NAT Gateway IDs." }
output "nat_private_ips"            { value = "${join(",", aws_nat_gateway.mod.*.private_ip) }"         description = "List of the NAT Gateway private IPs." }
output "nat_public_ips"             { value = "${join(",", aws_nat_gateway.mod.*.public_ip) }"          description = "List of the NAT Gateway public IPs." }
output "subnets_private_ids"        { value = "${join(",", aws_subnet.private.*.id) }"                  description = "List of the VPC private subnets IDs." }
output "subnets_private_cidr_block" { value = "${join(",", aws_subnet.private.*.cidr_block) }"          description = "List of the VPC private CIDR blocks." }
output "subnets_public_ids"         { value = "${join(",", aws_subnet.public.*.id) }"                   description = "List of the VPC public subnets IDs." }
output "subnets_public_cidr_block"  { value = "${join(",", aws_subnet.public.*.cidr_block) }"           description = "List of the VPC public CIDR blocks." }
output "rtb_private_ids"            { value = "${join(",", aws_route_table.private.*.id) }"             description = "List of the VPC Routing Tables private IDs." }
output "rtb_public_ids"             { value = "${join(",", aws_route_table.public.*.id) }"              description = "List of the VPC Routing Tables public IDs." }
output "route_private_rtb_ids"      { value = "${join(",", aws_route_table.private.*.route_table_id) }" description = "List of the VPC Routes private IDs." }
output "route_public_rtb_ids"       { value = "${join(",", aws_route_table.public.*.route_table_id) }"  description = "List of the VPC Routes public IDs." }
output "secondary_public_zone_id"   { value = "${aws_route53_zone.secondary_public.zone_id}"            description = "Route53 public hosted zone ID." }
output "secondary_private_zone_id"  { value = "${aws_route53_zone.secondary_private.zone_id}"           description = "Route53 private hosted zone ID." }