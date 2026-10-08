terraform {
  required_providers {
    snapcd = {
      source  = "registry.terraform.io/schrieksoft/snapcd"
      version = "1.5.0"
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
    key                         = "my-states/sample-snapcd.tfstate"
  }
}
