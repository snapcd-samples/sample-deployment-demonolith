# Supplied by terraform.tfvars.
variable "name_prefix" {
  description = "Prefix for every named resource in the deployment"
  type        = string
}

# Supplied by TF_VAR_resource_group_name in .env.
variable "resource_group_name" {
  description = "Resource group the whole deployment lands in"
  type        = string
}

variable "module_private_subnet_subnet_id" {
  type        = string
  description = "Upstream input from module \"networking\" output \"module_private_subnet_subnet_id\""
}

variable "module_public_subnet" {
  type        = string
  description = "Upstream input from module \"networking\" output \"module_public_subnet\""
}

variable "random_uuid_vpc_id" {
  type        = string
  description = "Upstream input from module \"networking\" output \"random_uuid_vpc_id\""
}

