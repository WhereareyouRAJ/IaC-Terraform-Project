variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}
variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster"
  type        = list(string)
      
}

variable "cluster_role_name" {  
  description = "The name of the IAM role to be used by the EKS cluster"
  type        = string
}