VPC terraform module
===========

[![GitHub release](https://img.shields.io/github/release/KoeSystems/terraform-aws-vpc.svg?style=plastic)](https://github.com/KoeSystems/terraform-aws-vpc/releases/latest)
[![Terraform version](https://img.shields.io/badge/terraform-0.11.x-brightgreen.svg?style=plastic)](https://github.com/hashicorp/terraform/blob/v0.11.7/CHANGELOG.md)
[![Terraform version](https://img.shields.io/badge/terraform-0.10.x-brightgreen.svg?style=plastic)](https://github.com/hashicorp/terraform/blob/v0.10.8/CHANGELOG.md)
[![Terraform version](https://img.shields.io/badge/terraform-0.9.x-yellowgreen.svg?style=plastic)](https://github.com/hashicorp/terraform/blob/v0.9.11/CHANGELOG.md)
[![GitHub license](https://img.shields.io/github/license/KoeSystems/terraform-aws-vpc.svg?style=plastic)](https://github.com/KoeSystems/terraform-aws-vpc/blob/master/LICENSE)

A terraform module to create an AWS VPC.

For security reasons:
- Default RTB is not associated with any VPC subnet.
- Default ACL DENY ALL.
- Default SG DENY ALL.

Module Input Variables
----------------------

- `name` - AWS VPC name
- `domain_name` (optional) - Domain Name used in the DHCP options. Will be used to complete unqualified DNS hostnames within the VPC. Default value `""`.
- `cidr_block` (optional) - VPC CIDR Block. Default value `10.0.0.0/16`.
- `ipv6_cidr_block` (optional) - Enable IPv6 in the VPC. Default value `false`.
- `ipv6_private_egress` (optional) - Enable IPv6 Egress Gateway for private subnets. Default value `false`.
- `tenancy` (optional) - Force the default hardware tenancy of any instance you launch in the VPC. Default value `default`.
- `enable_dns_support` (optional) - Indicates whether the DNS resolution is supported for the VPC. Default value `true`.
- `enable_dns_hostnames` (optional) - Indicates whether the instances launched in the VPC get public DNS hostnames. Default value `true`.
- `domain_name_servers` (optional) - DNS servers that will resolve hostnames. Default value `AmazonProvidedDNS`.
- `AZs` (optional) - Number of AWS AZs to be used (a,b,c,d,e).
- `enable_vpc_flow_logs` - Enable AWS VPC Flow Logs for this VPC. Default value `false`.
- `enable_nat_gw` - Create one NAT Gateway for each AZs. Default value `true`.
- `allow_all_ACL` - Add generic ACL rules to allow ALL traffic.

Caveats
----------------------
Adding IPv6 support to an already existing VPC with only IPv4 is not supported. You will have to destroy it and create a new VPC.

Usage examples
-----

```js
module "vpc" {
  source  = "github.com/KoeSystems/terraform-aws-vpc?ref=v0.1.1"
  name    = "vpc01"
}
```

Enable VPC Flow Logs
```js
module "vpc" {
  source  = "github.com/KoeSystems/terraform-aws-vpc"
  name    = "vpc01"
  vpc_flow_logs = true
}
```

Enable IPv6
```js
module "vpc" {
  source  = "github.com/KoeSystems/terraform-aws-vpc"
  name    = "vpc01"
  ipv6_cidr_block = true
}
```

Costs
=====

The terraform module will create a NAT Gateway for each AZs (by default = 3), you can reduce costs by reducing the number of AZs.
Also terraform will configure VPC Flow Logs by default to be able to trace all the network traffic within the VPC, this will generate some costs in AWS CloudWatch Logs.
Two Route53 will be created, one public and another private attached to the VPC.
 
Authors
=======

Originally created and maintained by [Koe](https://github.com/KoeSystems)

License
=======

MIT License. See LICENSE for full details.
