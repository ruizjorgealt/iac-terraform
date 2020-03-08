/* Variables */
variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "availability_zones" {
  type = "map"
  default = {
    "1" = "us-east-2a"
    "2" = "us-east-2b"
  }
}

variable "subnet_cidr" {
  type = "map"
  default = {
    "1" = "172.31.0.0/22"
    "2" = "172.31.4.0/22"
  }
}

variable "subnet_count" {
  default = "2"
}
