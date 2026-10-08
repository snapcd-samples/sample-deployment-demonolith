variable "client_id" {
  description = "Client ID for Snap CD authentication"
  type        = string
  default     = "default"
}

variable "client_secret" {
  description = "Client Secret for Snap CD authentication"
  type        = string
  sensitive   = true
  default     = "default"
}

variable "organization_id" {
  description = "Snap CD Organization ID"
  type        = string
  default     = "10000000-0000-0000-0000-000000000000"
}

variable "snapcd_server_url" {
  description = "Snap CD Server URL, reachable both from where this root is applied and from inside the Runner"
  type        = string
  default     = "http://localhost:5000"
}

variable "insecure_skip_verify" {
  description = "Skip TLS verification against the Snap CD Server"
  type        = bool
  default     = true
}

variable "create_stack" {
  description = "Create the Stack instead of reusing an existing one by name"
  type        = bool
  default     = false
}

variable "create_namespace" {
  description = "Create the Namespace instead of reusing an existing one by name"
  type        = bool
  default     = true
}

variable "stack_name" {
  description = "Name of the Stack to deploy into"
  type        = string
  default     = "default"
}

variable "runner_name" {
  description = "Name of the registered Runner that executes the modules"
  type        = string
  default     = "default"
}

variable "namespace_name" {
  description = "Name of the Namespace the modules deploy into"
  type        = string
  default     = "demonolith-bootstrap"
}

variable "engine" {
  description = "Engine the modules run with"
  type        = string
  default     = "OpenTofu"
}

variable "source_url" {
  description = "Git URL of the repository holding the new module directories"
  type        = string
}

variable "source_revision" {
  description = "Git revision (branch or tag) of the new module directories"
  type        = string
  default     = "main"
}

variable "source_subdirectory_prefix" {
  description = "Path from the repository root to the monolith root, with a trailing slash; empty when the monolith is the repository root"
  type        = string
  default     = ""
}

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

# Supplied by TF_VAR_resource_group_name in .env.
variable "resource_group_name" {
  description = "Resource group the whole deployment lands in"
  type        = string
}

