terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }

  // The monolith's own state lives in a remote S3-compatible store instead
  // of a local terraform.tfstate — a MinIO container standing in for a real
  // bucket (./step0_store.sh starts it). The endpoints/skip_* settings are
  // what point the s3 backend at a non-AWS store; nothing here touches AWS.
  //
  // The credentials (access_key/secret_key) are deliberately NOT here: they
  // are passed as -backend-config flags at init time (see
  // step2_baseline.sh). demonolith reads them from the init-time resolved
  // config and materializes them into gitignored per-module demono.env
  // files — secret-shaped backend settings never land in HCL.
  //
  // demonolith derives each new module's backend from this block: the key
  // is postfixed per module (my-states/sample.tfstate becomes
  // my-states/sample-networking.tfstate), so `migrate run` pushes every
  // module's state into the same bucket.
  backend "s3" {
    bucket = "tfstate"
    key    = "my-states/sample.tfstate"
    region = "us-east-1"

    endpoints                   = { s3 = "http://localhost:9000" }
    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

