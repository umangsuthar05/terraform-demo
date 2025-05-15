variable "subnets_cidr" {
  type    = list(any)
  default = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20", "172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"]
}

variable "availability_zones" {
  type    = list(any)
  default = ["us-east-1c", "us-east-1d", "us-east-1e", "us-east-1b", "us-east-1a", "us-east-1f"]
}