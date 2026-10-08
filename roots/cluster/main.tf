locals {
  cluster_name   = "${local.name}-cluster"
  environment    = "prod"
  name           = "${var.name_prefix}-${local.environment}"
  oncall         = jsondecode(data.http.oncall.response_body)
  oncall_team_id = local.oncall.team_id
}

data "http" "oncall" {
  url = "https://raw.githubusercontent.com/snapcd-samples/mock-datasource/main/oncall.json"
}

# Also external, also from GitHub.
module "cluster" {
  source              = "github.com/snapcd-samples/mock-module-kubernetes-cluster"
  resource_group_name = var.resource_group_name
  cluster_name        = local.cluster_name
  vpc_id              = var.random_uuid_vpc_id
  public_subnet_id    = var.module_public_subnet
  private_subnet_id   = var.module_private_subnet_subnet_id
  kubernetes_version  = "1.28"
  node_instance_type  = "m5.large"
  desired_capacity    = 2
}

resource "random_pet" "node_pool" {
  prefix = local.cluster_name
  keepers = {
    nodes       = "2"
    oncall_team = local.oncall_team_id
  }
}

