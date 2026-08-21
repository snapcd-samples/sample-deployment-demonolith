# ===========================================================================
# The monolith.
#
# One root, one state, everything in it: networking, a database, a Kubernetes
# cluster, and the app on top — plus the shared plumbing (platform context
# read from an external data source, a deploy key, locals) that all of them
# read. Every resource is a mock (random/tls/time providers), so this
# applies against nothing but the simulated state store; the reference
# structure is the point, not the infrastructure.
# ===========================================================================

# --- shared plumbing -------------------------------------------------------

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

data "http" "oncall" {
  url = "https://raw.githubusercontent.com/snapcd-samples/mock-datasource/main/oncall.json"
}

# The deployment signing key; its public half is read back through a data
# source and referenced by the app section. The key lives with the app: its
# PEM is provider-sensitive, and a sensitive value must not cross a carve
# boundary (see demonolith's LIMITATIONS.md), so everything that reads it is
# placed together.
# @demono:move app
resource "tls_private_key" "deploy_signer" {
  algorithm = "ED25519"
}

data "tls_public_key" "deploy_key" {
  private_key_pem = tls_private_key.deploy_signer.private_key_pem
}

# --- networking ------------------------------------------------------------

# @demono:move networking
resource "random_uuid" "vpc_id" {}

# @demono:move networking
resource "random_pet" "network_name" {
  prefix = var.name_prefix
  length = 2
  keepers = {
    platform = local.platform.name
  }
}

# @demono:move networking
module "public_subnet" {
  source     = "./modules/subnet"
  vpc_id     = random_uuid.vpc_id.result
  cidr_block = var.public_subnet_cidr
  name       = "${local.name}-public"
}

# @demono:move networking
module "private_subnet" {
  source     = "./modules/subnet"
  vpc_id     = random_uuid.vpc_id.result
  cidr_block = var.private_subnet_cidr
  name       = "${local.name}-private"
}

# @demono:move networking
resource "time_sleep" "network_propagation" {
  create_duration = "1s"
  depends_on      = [random_uuid.vpc_id, module.public_subnet, module.private_subnet]
}

# @demono:move networking
resource "random_uuid" "nat_gateway_id" {
  depends_on = [time_sleep.network_propagation]
}

# --- database --------------------------------------------------------------

# An external module, pulled straight from GitHub (not a Snap CD module).
# @demono:move database
module "database" {
  source              = "github.com/snapcd-samples/mock-module-database"
  resource_group_name = var.resource_group_name
  database_name       = local.database_name
  database_sku        = "db.t3.small"
  deploy_to_subnet_id = module.private_subnet.subnet_id
}

# @demono:move database
resource "random_uuid" "database_firewall_rule" {
  keepers = {
    subnet_cidr = module.private_subnet.cidr_block
    port        = tostring(var.database_port)
    platform_id = local.platform_id
  }
}

# --- cluster ---------------------------------------------------------------

# Also external, also from GitHub.
# @demono:move cluster
module "cluster" {
  source              = "github.com/snapcd-samples/mock-module-kubernetes-cluster"
  resource_group_name = var.resource_group_name
  cluster_name        = local.cluster_name
  vpc_id              = random_uuid.vpc_id.result
  public_subnet_id    = module.public_subnet.subnet_id
  private_subnet_id   = module.private_subnet.subnet_id
  kubernetes_version  = "1.28"
  node_instance_type  = "m5.large"
  desired_capacity    = 2
  depends_on          = [time_sleep.network_propagation]
}

# @demono:move cluster
resource "random_pet" "node_pool" {
  prefix = local.cluster_name
  keepers = {
    nodes       = "2"
    oncall_team = local.oncall_team_id
  }
}

# --- app -------------------------------------------------------------------

# @demono:move app
resource "random_password" "app_session_secret" {
  length  = 24
  special = false
}

# @demono:move app
resource "random_pet" "app_release" {
  prefix = local.app_name
  keepers = {
    cluster     = module.cluster.cluster_id
    db_endpoint = module.database.database_endpoint
    db_port     = tostring(var.database_port)
    replicas    = "3"
    deploy_key  = local.deploy_key_fingerprint
    zone        = local.network_zone
    platform_id = local.platform_id
    oncall_team = local.oncall_team_id
  }
}

# @demono:move app
module "storefront_dns" {
  source = "./modules/dns"
  zone   = local.network_zone
  name   = local.app_name
  target = module.cluster.cluster_endpoint
}

# --- ops odds and ends -----------------------------------------------------

resource "random_uuid" "audit_log_bucket_id" {}

resource "random_pet" "backup_plan" {
  length = 2
}
