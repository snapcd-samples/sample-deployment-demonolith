# Supplied only as a -var flag — the value exists nowhere on disk, which is
# exactly the case the migration has to re-supply by hand (state does not
# record inputs).
variable "database_port" {
  description = "Port the database listens on"
  type        = number
}

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

variable "module_private_subnet_cidr_block" {
  type        = string
  description = "Upstream input from module \"networking\" output \"module_private_subnet_cidr_block\""
}

variable "module_private_subnet_subnet_id" {
  type        = string
  description = "Upstream input from module \"networking\" output \"module_private_subnet_subnet_id\""
}

