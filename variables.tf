variable "ami_value" {
  description = "AMI for the instance"
  type        = string
  default     = "ami-04a81a99f5ec58529"
}

variable "instance_type_value" {
  description = "Instance type for the instance"
  type        = string
  default     = "t2.micro"
}
variable "cidr" {
  default = "10.0.0.0/16"
}
