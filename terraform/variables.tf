variable "cluster_name" {
  description = "The name to give to this environment. Will be used for naming various resources."
  type        = string
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
}

variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "ec2_key_name" {
  description = "The name of the public key to inject to instances launched in the VPC"
  type        = string
}

variable "ec2_key" {
  description = "The public key to inject to instances launched in the VPC"
  type        = string
}

# Reference: https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-dedicated-instances.html
variable "vpc_instance_tenancy" {
  description = "How are instances distributed across the underlying physical hardware"
  type        = string
  default     = "default"
}

variable "aws_az1" {
  description = "The AZ where public-subnet1 will reside"
  type        = string
}

variable "public_subnet1_cidr" {
  description = "The cidr block to use for public-subnet1"
  type        = string
}

variable "public_subnet2_cidr" {
  description = "The cidr block to use for public-subnet2"
  type        = string
}

variable "private_subnet1_cidr" {
  description = "The cidr block to use for private-subnet1"
  type        = string
}

variable "private_subnet2_cidr" {
  description = "The cidr block to use for private-subnet2"
  type        = string
}

variable "db_multi_az" {
  description = "Should the database be multi AZ or not?"
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Should we skip snapshot creation just before deleting the DB?"
  type        = bool
  default     = false
}

variable "k8s_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "k8s_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "k8s_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "k8s_node_instance_types" {
  description = "List of instance types associated with the EKS Node Group"
  type        = list(any)
  default     = ["t3.medium"]
}
