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

locals {
  app_name               = "${local.name}-storefront"
  deploy_key_fingerprint = data.tls_public_key.deploy_key.public_key_fingerprint_md5
  environment            = "prod"
  name                   = "${var.name_prefix}-${local.environment}"
  network_zone           = "${var.random_pet_network_name}.internal"
  oncall                 = jsondecode(data.http.oncall.response_body)
  oncall_team_id         = local.oncall.team_id
  platform               = jsondecode(data.http.platform.response_body)
  platform_id            = local.platform.id
}

data "http" "oncall" {
  url = "https://raw.githubusercontent.com/snapcd-samples/mock-datasource/main/oncall.json"
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

data "tls_public_key" "deploy_key" {
  private_key_pem = tls_private_key.deploy_signer.private_key_pem
}

module "storefront_dns" {
  source = "../../modules/dns"
  zone   = local.network_zone
  name   = local.app_name
  target = var.module_cluster_cluster_endpoint
}

resource "random_password" "app_session_secret" {
  length  = 24
  special = false
}

resource "random_pet" "app_release" {
  prefix = local.app_name
  keepers = {
    cluster     = var.module_cluster_cluster_id
    db_endpoint = var.module_database
    db_port     = tostring(var.database_port)
    replicas    = "3"
    deploy_key  = local.deploy_key_fingerprint
    zone        = local.network_zone
    platform_id = local.platform_id
    oncall_team = local.oncall_team_id
  }
}

# The deployment signing key; its public half is read back through a data
# source and referenced by the app section. The key lives with the app: its
# PEM is provider-sensitive, and a sensitive value must not cross a carve
# boundary (see demonolith's LIMITATIONS.md), so everything that reads it is
# placed together.
resource "tls_private_key" "deploy_signer" {
  algorithm = "ED25519"
}

