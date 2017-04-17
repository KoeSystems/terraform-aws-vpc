variable "name"                 { }
variable "domain_name"          { default = "" }
variable "cidr_block"           { default = "10.0.0.0/16"}
variable "tenancy"              { default = "default" }
variable "enable_dns_support"   { default = true }
variable "enable_dns_hostnames" { default = true }
variable "ipv6_cidr_block"      { default = false }
variable "domain_name_servers"  { default = [ "AmazonProvidedDNS" ] }
variable "AZs"                  { default = 3 }