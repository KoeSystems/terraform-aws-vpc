variable "name"                 {                                       description = "AWS VPC name. This would be used as prefix in all the resources to support multiple VPCs."}
variable "domain_name"          {                                       description = "AWS Route53 hosted zone name to be attached to the VPC." }
variable "cidr_block"           { default     = "10.0.0.0/16"           description = "CIDR block assigned to the VPC." }
variable "ipv6_cidr_block"      { default     = false                   description = "Enable IPv6." }
variable "tenancy"              { default     = "default"               description = "Sets where the EC2 instance will run. Accepted values are 'default', 'dedicated' or 'host'." }
variable "enable_dns_support"   { default     = true                    description = "Queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC IPv4 network range plus two will succeed." }
variable "enable_dns_hostnames" { default     = true                    description = "Instances in the VPC get public DNS hostnames, but only if the enable_dns_support attribute is also set to true." }
variable "domain_name_servers"  { default     = [ "AmazonProvidedDNS" ] description = "Sets the DNS server configured in the DHCP Options." }
variable "AZs"                  { default     = 3                       description = "Number of Availability Zones we want to have." }
variable "enable_vpc_flow_logs" { default     = false                   description = "Enable VPC Flow logs." }
variable "enable_nat_gw"        { default     = true                    description = "Create one NAT Gateway for each AZs." }