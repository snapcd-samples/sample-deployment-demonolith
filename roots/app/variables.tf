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

variable "module_cluster_cluster_endpoint" {
  type        = string
  description = "Upstream input from module \"cluster\" output \"module_cluster_cluster_endpoint\""
}

variable "module_cluster_cluster_id" {
  type        = string
  description = "Upstream input from module \"cluster\" output \"module_cluster_cluster_id\""
}

variable "module_database" {
  type        = string
  description = "Upstream input from module \"database\" output \"module_database\""
}

variable "random_pet_network_name" {
  type        = string
  description = "Upstream input from module \"networking\" output \"random_pet_network_name\""
}

