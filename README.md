VPC terraform module
===========

A terraform module to create an AWS VPC.

For security reasons, any VPC subnet or VPC Route Table has been defined as Default or Main. That it means you will have to specific always where you want to launch your instances.


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

Usage examples
-----

```js
module "vpc" {
  source  = "github.com/KoeSystems/tf_aws_vpc"
  name    = "vpc01"
}
```

Outputs
=======

 - `public_ip` - comma separated list of public IPs allocated
 
Authors
=======

Originally created and maintained by [Koe](https://github.com/KoeSystems)

License
=======

MIT License. See LICENSE for full details.