resource "snapcd_stack" "this" {
  count = var.create_stack ? 1 : 0
  name  = var.stack_name
}

data "snapcd_stack" "this" {
  count = var.create_stack ? 0 : 1
  name  = var.stack_name
}

resource "snapcd_namespace" "this" {
  count                               = var.create_namespace ? 1 : 0
  name                                = var.namespace_name
  stack_id                            = local.stack_id
  default_engine                      = var.engine
  default_trigger_path_filter_enabled = true
}

data "snapcd_namespace" "this" {
  count    = var.create_namespace ? 0 : 1
  name     = var.namespace_name
  stack_id = local.stack_id
}

locals {
  stack_id     = one(concat(snapcd_stack.this[*].id, data.snapcd_stack.this[*].id))
  namespace_id = one(concat(snapcd_namespace.this[*].id, data.snapcd_namespace.this[*].id))
}

data "snapcd_runner" "this" {
  name = var.runner_name
}

resource "snapcd_module" "app" {
  name                = "app"
  namespace_id        = local.namespace_id
  source_url          = var.source_url
  source_revision     = var.source_revision
  source_subdirectory = "${var.source_subdirectory_prefix}roots/app"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

resource "snapcd_module" "cluster" {
  name                = "cluster"
  namespace_id        = local.namespace_id
  source_url          = var.source_url
  source_revision     = var.source_revision
  source_subdirectory = "${var.source_subdirectory_prefix}roots/cluster"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

resource "snapcd_module" "database" {
  name                = "database"
  namespace_id        = local.namespace_id
  source_url          = var.source_url
  source_revision     = var.source_revision
  source_subdirectory = "${var.source_subdirectory_prefix}roots/database"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

resource "snapcd_module" "legacy" {
  name                = "legacy"
  namespace_id        = local.namespace_id
  source_url          = var.source_url
  source_revision     = var.source_revision
  source_subdirectory = "${var.source_subdirectory_prefix}roots/legacy"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

resource "snapcd_module" "networking" {
  name                = "networking"
  namespace_id        = local.namespace_id
  source_url          = var.source_url
  source_revision     = var.source_revision
  source_subdirectory = "${var.source_subdirectory_prefix}roots/networking"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

resource "snapcd_module_input_from_output" "app_module_cluster_cluster_endpoint" {
  input_kind       = "Param"
  module_id        = snapcd_module.app.id
  name             = "module_cluster_cluster_endpoint"
  output_module_id = snapcd_module.cluster.id
  output_name      = "module_cluster_cluster_endpoint"
}

resource "snapcd_module_input_from_output" "app_module_cluster_cluster_id" {
  input_kind       = "Param"
  module_id        = snapcd_module.app.id
  name             = "module_cluster_cluster_id"
  output_module_id = snapcd_module.cluster.id
  output_name      = "module_cluster_cluster_id"
}

resource "snapcd_module_input_from_output" "app_module_database" {
  input_kind       = "Param"
  module_id        = snapcd_module.app.id
  name             = "module_database"
  output_module_id = snapcd_module.database.id
  output_name      = "module_database"
}

resource "snapcd_module_input_from_output" "app_random_pet_network_name" {
  input_kind       = "Param"
  module_id        = snapcd_module.app.id
  name             = "random_pet_network_name"
  output_module_id = snapcd_module.networking.id
  output_name      = "random_pet_network_name"
}

resource "snapcd_module_input_from_output" "cluster_module_private_subnet_subnet_id" {
  input_kind       = "Param"
  module_id        = snapcd_module.cluster.id
  name             = "module_private_subnet_subnet_id"
  output_module_id = snapcd_module.networking.id
  output_name      = "module_private_subnet_subnet_id"
}

resource "snapcd_module_input_from_output" "cluster_module_public_subnet" {
  input_kind       = "Param"
  module_id        = snapcd_module.cluster.id
  name             = "module_public_subnet"
  output_module_id = snapcd_module.networking.id
  output_name      = "module_public_subnet"
}

resource "snapcd_module_input_from_output" "cluster_random_uuid_vpc_id" {
  input_kind       = "Param"
  module_id        = snapcd_module.cluster.id
  name             = "random_uuid_vpc_id"
  output_module_id = snapcd_module.networking.id
  output_name      = "random_uuid_vpc_id"
}

resource "snapcd_module_input_from_output" "database_module_private_subnet_cidr_block" {
  input_kind       = "Param"
  module_id        = snapcd_module.database.id
  name             = "module_private_subnet_cidr_block"
  output_module_id = snapcd_module.networking.id
  output_name      = "module_private_subnet_cidr_block"
}

resource "snapcd_module_input_from_output" "database_module_private_subnet_subnet_id" {
  input_kind       = "Param"
  module_id        = snapcd_module.database.id
  name             = "module_private_subnet_subnet_id"
  output_module_id = snapcd_module.networking.id
  output_name      = "module_private_subnet_subnet_id"
}

resource "snapcd_depends_on_module" "cluster_on_networking" {
  module_id            = snapcd_module.cluster.id
  depends_on_module_id = snapcd_module.networking.id
}

resource "snapcd_module_input_from_literal" "app_database_port" {
  input_kind    = "Param"
  module_id     = snapcd_module.app.id
  name          = "database_port"
  literal_value = var.database_port
  type          = "String"
}

resource "snapcd_module_input_from_literal" "app_name_prefix" {
  input_kind    = "Param"
  module_id     = snapcd_module.app.id
  name          = "name_prefix"
  literal_value = var.name_prefix
  type          = "String"
}

resource "snapcd_module_input_from_literal" "cluster_name_prefix" {
  input_kind    = "Param"
  module_id     = snapcd_module.cluster.id
  name          = "name_prefix"
  literal_value = var.name_prefix
  type          = "String"
}

resource "snapcd_module_input_from_literal" "cluster_resource_group_name" {
  input_kind    = "Param"
  module_id     = snapcd_module.cluster.id
  name          = "resource_group_name"
  literal_value = var.resource_group_name
  type          = "String"
}

resource "snapcd_module_input_from_literal" "database_database_port" {
  input_kind    = "Param"
  module_id     = snapcd_module.database.id
  name          = "database_port"
  literal_value = var.database_port
  type          = "String"
}

resource "snapcd_module_input_from_literal" "database_name_prefix" {
  input_kind    = "Param"
  module_id     = snapcd_module.database.id
  name          = "name_prefix"
  literal_value = var.name_prefix
  type          = "String"
}

resource "snapcd_module_input_from_literal" "database_resource_group_name" {
  input_kind    = "Param"
  module_id     = snapcd_module.database.id
  name          = "resource_group_name"
  literal_value = var.resource_group_name
  type          = "String"
}

resource "snapcd_module_input_from_literal" "networking_name_prefix" {
  input_kind    = "Param"
  module_id     = snapcd_module.networking.id
  name          = "name_prefix"
  literal_value = var.name_prefix
  type          = "String"
}

resource "snapcd_module_input_from_literal" "networking_private_subnet_cidr" {
  input_kind    = "Param"
  module_id     = snapcd_module.networking.id
  name          = "private_subnet_cidr"
  literal_value = var.private_subnet_cidr
  type          = "String"
}

resource "snapcd_module_input_from_literal" "networking_public_subnet_cidr" {
  input_kind    = "Param"
  module_id     = snapcd_module.networking.id
  name          = "public_subnet_cidr"
  literal_value = var.public_subnet_cidr
  type          = "String"
}

