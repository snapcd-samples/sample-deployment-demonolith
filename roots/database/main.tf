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

locals {
  database_name = "${local.name}-orders"
  environment   = "prod"
  name          = "${var.name_prefix}-${local.environment}"
  platform      = jsondecode(data.http.platform.response_body)
  platform_id   = local.platform.id
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

# An external module, pulled straight from GitHub (not a Snap CD module).
module "database" {
  source              = "github.com/snapcd-samples/mock-module-database"
  resource_group_name = var.resource_group_name
  database_name       = local.database_name
  database_sku        = "db.t3.small"
  deploy_to_subnet_id = var.module_private_subnet_subnet_id
}

resource "random_uuid" "database_firewall_rule" {
  keepers = {
    subnet_cidr = var.module_private_subnet_cidr_block
    port        = tostring(var.database_port)
    platform_id = local.platform_id
  }
}

