# Supplied by terraform.tfvars.
variable "name_prefix" {
  description = "Prefix for every named resource in the deployment"
  type        = string
}

# Supplied by terraform.tfvars.
variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

# Supplied by terraform.tfvars.
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

