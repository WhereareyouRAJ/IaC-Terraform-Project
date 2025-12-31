variable "instance_name" {
  description = "The name tag to assign to the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "The type of instance to use for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}
variable "volume_size" {
  description = "The size of the root EBS volume in GB"
  type        = number
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the EC2 instance"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instance will be deployed"
  type        = string
}