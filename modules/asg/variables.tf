variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "instance_type" { type = string default = "t3.micro" }
variable "desired_capacity" { type = number default = 2 }
variable "min_size" { type = number default = 2 }
variable "max_size" { type = number default = 4 }
variable "instance_profile_name" { type = string }
variable "nginx_port" { type = number default = 80 }
variable "tags" { type = map(string) default = {} }
