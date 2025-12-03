variable "name" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = map(string) }
variable "private_subnets" { type = map(string) }
variable "azs" { type = list(string) }
variable "tags" { type = map(string) default = {} }
