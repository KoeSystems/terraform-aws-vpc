variable "name"                 {                                       description = "AWS VPC name. This would be used as prefix in all the resources to support multiple VPCs."}
variable "domain_name"          { default     = ""                      description = "Domain name used with DHCP options in the VPC." }
variable "cidr_block"           { default     = "10.0.0.0/16"           description = "CIDR block assigned to the VPC." }
variable "ipv6_cidr_block"      { default     = false                   description = "Enable IPv6." }
variable "ipv6_private_egress"  { default     = false                   description = "Enable IPv6 Egress Gateway for private subnets." }
variable "tenancy"              { default     = "default"               description = "Sets where the EC2 instance will run. Accepted values are 'default', 'dedicated' or 'host'." }
variable "enable_dns_support"   { default     = true                    description = "Queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC IPv4 network range plus two will succeed." }
variable "enable_dns_hostnames" { default     = true                    description = "Instances in the VPC get public DNS hostnames, but only if the enable_dns_support attribute is also set to true." }
variable "AZs"                  { default     = "a,b,c"                 description = "String with the Availability Zones we want to have." }
variable "enable_vpc_flow_logs" { default     = false                   description = "Enable VPC Flow logs." }
variable "enable_nat_gw"        { default     = true                    description = "Create one NAT Gateway for each AZs." }
variable "allow_all_ACL"        { default     = true                    description = "Add generic ACL rules to allow ALL traffic." }
variable "only_public"          { default     = false                   description = "Create only one public subnet." }
