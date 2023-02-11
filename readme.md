# My awesome TF module

## Usage
Sample usage:
~~~
module "compute_structure" {
  source = "https://github.com/mayoloving/mymodules/compute_module"

  private_bucket_name = "mybucket"
  ec2_instance_type   = "t3a.small"
  ec2_ami_type        = <your ami type>

  tg_path                = "/"
  tg_port                = 80
  tg_interval            = 30
  tg_protocol            = "HTTP"
  tg_timeout             = 30
  tg_healthy_threshold   = 5
  tg_unhealthy_threshold = 3

  instance_name  = "myec2"
  owner_tag      = <your name>
  bootcamp_tag   = <number>
  expiration_tag = <date>

  vpc_id  = module.network_structure.vpc_id
  subnets = module.network_structure.subnets_ids
}

module "network_structure" {
  source = "https://github.com/mayoloving/mymodules/network_module"

  vpc_cidr       = "10.16.0.0/16"
  pubsub_cidrs   = ["10.16.0.0/24", "10.16.1.0/24"]
  owner_tag      = <your name>
  bootcamp_tag   = <number>
  expiration_tag = <date>
}
~~~