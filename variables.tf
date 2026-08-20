# No defaults on purpose: every value arrives through one of the monolith's
# input channels — terraform.tfvars, TF_VAR_* environment (.env), or a -var
# flag (see step2_baseline.sh) — so each channel is load-bearing and a missed
# one fails loudly.

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

# Supplied by TF_VAR_vpc_cidr_block in .env.
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

# Supplied by terraform.tfvars.
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

# Supplied by terraform.tfvars.
variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

# Supplied only as a -var flag — the value exists nowhere on disk, which is
# exactly the case the migration has to re-supply by hand (state does not
# record inputs).
variable "database_port" {
  description = "Port the database listens on"
  type        = number
}
