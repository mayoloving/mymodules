variable "vpc_cidr" {
  type        = string
  description = "CIDR for vpc network"
}

variable "pubsub_cidrs" {
  type = list(any)
}

variable "subnet_count" {
  type    = number
  default = 2
}

# tags
variable "owner_tag" {
  type = string
}

variable "bootcamp_tag" {
  type = string
}

variable "expiration_tag" {
  type = string
}
