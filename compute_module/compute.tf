# SG for EC2
resource "aws_security_group" "yotam-sg-terraformeasy" {
  name   = "yotam-sg-terraformeasy"
  vpc_id = var.vpc_id

  #Incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.yotam-sg-albeasy.id] # to check again
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================

# Create 2 EC2 (depends on count)
resource "aws_instance" "yotambenz-tf-ec2" {
  ami                         = var.ec2_ami_type
  instance_type               = var.ec2_instance_type
  count                       = var.ec2_count
  subnet_id                   = var.subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.yotam-sg-terraformeasy.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce
  sudo systemctl start docker
  sudo systemctl enable docker

  sudo docker pull adongy/hostname-docker
  sudo docker run --name yot -dt -p 80:3000 adongy/hostname-docker
  EOF

  tags = {
    Name            = "${var.instance_name}-${count.index}"
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }
}

#=======================================ALB=============================================


# SG for alb
resource "aws_security_group" "yotam-sg-albeasy" {
  name   = "yotam-sg-albeasy"
  vpc_id = var.vpc_id

  #Incoming traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================

# create target-group
resource "aws_lb_target_group" "doiteasy-yotambenz-tg" {
  name        = "doiteasy-yotambenz-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.tg_path
    port                = var.tg_port
    interval            = var.tg_interval
    protocol            = var.tg_protocol
    timeout             = var.tg_timeout
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
  }

  tags = {
    Name            = "doiteasy-yotambenz-tg"
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }
}

# create ALB 
resource "aws_lb" "yotambenz-alb" {
  name               = "alb-doiteasy"
  internal           = false
  security_groups    = [aws_security_group.yotam-sg-albeasy.id]
  subnets            = var.subnets
  ip_address_type    = "ipv4"
  load_balancer_type = "application"

  tags = {
    Name            = "alb-doiteasy"
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }
}

# alb listener
resource "aws_alb_listener" "yotam-alb-listener" {
  load_balancer_arn = aws_lb.yotambenz-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.doiteasy-yotambenz-tg.arn
    type             = "forward"
  }

}

# attachment to alb
resource "aws_lb_target_group_attachment" "attach-yotambenz-tg" {
  target_group_arn = aws_lb_target_group.doiteasy-yotambenz-tg.arn
  count            = var.ec2_count
  target_id        = aws_instance.yotambenz-tf-ec2[count.index].id
  port             = 80
}

# ==================================S3 & DynamoDB============================================

# Create S3 bucket
resource "aws_s3_bucket" "yotambenz_s3_bucket" {
  bucket = var.private_bucket_name

}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.yotambenz_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.yotambenz_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==============================================================================

# # Create DynamoDB for locking
# resource "aws_db_instance" "default" {
#   name = "terraform-state-locking"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
