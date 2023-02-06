variable "private_bucket_name" {
  type        = string
  description = "private s3 bucket"
}

variable "ec2_instance_type" {
  type        = string
  description = "instance type for ec2"
}

variable "ec2_ami_type" {
  type        = string
  description = "ami type for ec2"
}

variable "ec2_count" {
  type    = number
  default = 2
}

variable "subnets" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

# tags

variable "instance_name" {
  type = string
}

variable "owner_tag" {
  type = string
}

variable "bootcamp_tag" {
  type = string
}

variable "expiration_tag" {
  type = string
}

# target group health_check

variable "tg_path" {
  type = string
}
variable "tg_port" {
  type = number
}
variable "tg_interval" {
  type = number
}
variable "tg_protocol" {
  type = string
}
variable "tg_timeout" {
  type = number
}
variable "tg_healthy_threshold" {
  type = number
}
variable "tg_unhealthy_threshold" {
  type = number
}
