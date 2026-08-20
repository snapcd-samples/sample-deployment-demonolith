locals {
  environment = "prod"
  name        = "${var.name_prefix}-${local.environment}"

  database_name = "${local.name}-orders"
  cluster_name  = "${local.name}-cluster"
  app_name      = "${local.name}-storefront"

  # Values derived from resources and data sources; consumed on the far side
  # of future seams.
  network_zone           = "${random_pet.network_name.id}.internal"
  deploy_key_fingerprint = data.tls_public_key.deploy_key.public_key_fingerprint_md5

  # The external context, decoded once; consumers reference these locals.
  platform       = jsondecode(data.http.platform.response_body)
  oncall         = jsondecode(data.http.oncall.response_body)
  platform_id    = local.platform.id
  oncall_team_id = local.oncall.team_id
}
