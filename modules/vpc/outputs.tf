output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  value = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id
  ]
}


output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.gw.id
}