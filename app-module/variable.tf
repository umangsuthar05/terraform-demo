variable "stack_name" {
  type = string
  description = "Name of the stack"
}

variable "image_id" {
  type = string
  description = "Image ID of the instance"
  default = "ami-0150e981100558599" #AMI-2023 
}

variable "instance_type" {
  type = string
  description = "Instance type of the instance"
  default = "t3.small"
}

variable "pem_key_name" {
  type = string
  description = "PEM key name of the instance"
}

variable "vpc_id" {
  type = string
  description = "VPC ID of the instance"  
}

variable "detailed_ec2_monitoring" {
  type = bool
  description = "Enable detailed monitoring of the instance"
  default = false
}

variable "volume_size" {
  type = number
  description = "Volume size of the instance"
  default = 20
}

variable "environment" {
  type = string
  description = "Environment of the instance"
}

variable "health_check_listener_arn" {
  type = string
  description = "Health check listener ARN of the instance" 
  
}

variable "elb_security_group_id" {
  type = string
  description = "ELB security group ID of the instance"
  
}

