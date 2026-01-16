# variable is also type of block


variable "ec2_instance_type" {
  default = "t2.micro"
  type    = string
}

variable "ec2_root_storage_size" {
  default = 15
  type    = number
}

variable "ec2_ami_id" {
  default = "ami-02b8269d5e85954ef"
  type    = string
}

variable "ec2_name" {
  default = "CWS-instance"
  type    = string
}

# this variable for conditional epressions

variable "ec2_default_root_storage_size" {
  default = 10
  type = number
}

variable "env" {
  default = "prod"
  type = string
}