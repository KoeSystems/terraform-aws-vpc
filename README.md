VPC terraform module
===========

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
- `tenancy` (optional) - Force the default hardware tenancy of any instance you launch in the VPC. Default value `default`.
- `enable_dns_support` (optional) - Indicates whether the DNS resolution is supported for the VPC. Default value `true`.
- `enable_dns_hostnames` (optional) - Indicates whether the instances launched in the VPC get public DNS hostnames. Default value `true`.
- `ipv6_cidr_block` (optional) - Enable IPv6 in the VPC. Default value `false`.
- `domain_name_servers` (optional) - DNS servers that will resolve hostnames. Default value `AmazonProvidedDNS`.
- `AZs` (optional) - Number of AWS AZs to be used (a,b,c,d,e).
- `enable_vpc_flow_logs` - Enable AWS VPC Flow Logs for this VPC. Default value `false`.

Usage examples
-----

```js
module "vpc" {
  source  = "github.com/KoeSystems/tf_aws_vpc"
  name    = "vpc01"
}
```

Enable VPC Flow Logs
```js
module "vpc" {
  source  = "github.com/KoeSystems/tf_aws_vpc"
  name    = "vpc01"
  vpc_flow_logs = true
}
```

Outputs
=======

 - `public_ip` - comma separated list of public IPs allocated

Costs
=====

The terraform module will create a NAT Gateway for each AZs (by default = 3), you can reduce costs by reducing the number of AZs.
Also terraform will configure VPC Flow Logs by default to be able to trace all the network traffic within the VPC, this will generate some costs in AWS CloudWatch Logs.
 
Authors
=======

Originally created and maintained by [Koe](https://github.com/KoeSystems)

License
=======

MIT License. See LICENSE for full details.