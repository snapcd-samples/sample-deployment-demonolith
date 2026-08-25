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

  backend "s3" {
    bucket                      = "tfstate"
    endpoints                   = { s3 = "http://localhost:9000" }
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    key                         = "my-states/sample-networking.tfstate"
  }
}
