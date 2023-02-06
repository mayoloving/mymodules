output "vpc_id" {
  value = aws_vpc.yotambenz-tf-vpc.id
}

output "subnets_ids" {
  value = tolist(aws_subnet.publicsubnets[*].id)
}
