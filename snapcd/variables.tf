// The defaults below work out of the box against the pre-configured
// "snapcd-selfhosted-deployment-docker", matching ../../sample-deployment.

//// Needed to init provider
variable "client_id" {
  default = "default"
}
variable "client_secret" {
  default   = "default"
  sensitive = true
}
variable "organization_id" {
  default = "10000000-0000-0000-0000-000000000000"
}

variable "insecure_skip_verify" {
  default = true
  // set to false if server has valid certifcate; e.g. if snapcd_server_url==https://snapcd.io
}
variable "snapcd_server_url" {
  default = "http://localhost:5000"
  // The URL you use to reach the Snap CD Server from where you run `tofu apply`.
  // - snapcd-deployment-docker: "http://localhost:5000"
  // - SnapCd.Server.Host (C# project): "https://localhost:20002"
  // - SaaS subscription: "https://snapcd.io"
}


//// The deployment

variable "snapcd_server_url_from_runner" {
  default = "http://snapcd-server:5000"
  // The URL the Runner uses to reach the Snap CD Server. This is used in the
  // State Store backend config — OpenTofu runs inside the Runner container, so
  // the URL must be reachable from there (e.g. a Docker network hostname).
  // - snapcd-deployment-docker: "http://snapcd-server:5000"
  // - SnapCd.Server.Host (C# project): "https://localhost:20002"
  // - SaaS subscription: "https://snapcd.io"
}
variable "runner_name" {
  default = "default"
}
variable "stack_name" {
  default = "default"
}
variable "namespace_name" {
  default = "sample-deployment-demonolith"
}
variable "module_name" {
  default = "monolith"
  // Also the key the monolith's state is stored under, via SNAPCD_MODULE_NAME.
}

variable "source_url" {
  default = "https://github.com/snapcd-samples/sample-deployment-demonolith.git"
}
variable "branch_name" {
  default = "test/snapcd"
  // The branch Snap CD deploys. Switch it to redeploy the module from another
  // branch; a prove job runs a ref of its own without changing this.
}
variable "engine" {
  default = "OpenTofu"
}


//// The monolith's own inputs
//
// The sample's scripts spread these across four channels — terraform.tfvars,
// TF_VAR_* in the environment, a -var flag, and -backend-config — to show what
// demonolith copes with. A Snap CD module declares them all as parameters.

variable "name_prefix" {
  default = "acme"
}
variable "resource_group_name" {
  default = "acme-prod"
}
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}
variable "database_port" {
  default = "5432"
}
