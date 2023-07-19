variable "region" {
  type        = string
  description = "The AWS region used for the infrastructure."
  default     = "eu-west-1"
}

variable "app_vpc_cidr_block" {
  type        = string
  description = "The cidr block dedicated to the app's vpc."
  default     = "10.0.0.0/16"
}

variable "project" {
  type        = string
  description = "The name of the project all the infrastructure is a part of."
  default     = "app"

}

variable "az" {
  type        = list(string)
  description = "The aws availability zones."
  default     = ["eu-west-1a", "eu-west-1b"]

}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "A list of the cidr blocks used by the private subnets."
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "A list of the cidr blocks used by the public subnets."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "allowed_cidr_block_access" {
  type        = string
  description = "The destination cidr block to the internet."
  default     = "0.0.0.0/0"
}

