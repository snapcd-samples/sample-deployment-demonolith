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

locals {
  environment = "prod"
  name        = "${var.name_prefix}-${local.environment}"
  platform    = jsondecode(data.http.platform.response_body)
}

# Deployment context, read live from external sources — the platform
# registry's record for this deployment, and the on-call team that owns it
# (stationary JSON served raw from a public repo, standing in for a real
# platform API). Consumed by the networking, database, cluster, and app
# sections below — a data source is never decorated; it follows its
# consumers into every new module that reads it, and is read fresh on every
# plan.
data "http" "platform" {
  url = "https://raw.githubusercontent.com/snapcd-samples/mock-datasource/main/platform.json"
}

module "private_subnet" {
  source     = "../../modules/subnet"
  vpc_id     = random_uuid.vpc_id.result
  cidr_block = var.private_subnet_cidr
  name       = "${local.name}-private"
}

module "public_subnet" {
  source     = "../../modules/subnet"
  vpc_id     = random_uuid.vpc_id.result
  cidr_block = var.public_subnet_cidr
  name       = "${local.name}-public"
}

resource "random_pet" "network_name" {
  prefix = var.name_prefix
  length = 2
  keepers = {
    platform = local.platform.name
  }
}

resource "random_uuid" "nat_gateway_id" {
  depends_on = [time_sleep.network_propagation]
}

resource "random_uuid" "vpc_id" {}

resource "time_sleep" "network_propagation" {
  create_duration = "1s"
  depends_on      = [random_uuid.vpc_id, module.public_subnet, module.private_subnet]
}

