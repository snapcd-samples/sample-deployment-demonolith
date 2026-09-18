terraform {
  required_providers {
    snapcd = {
      source  = "registry.terraform.io/schrieksoft/snapcd"
      version = "1.5.0"
    }
  }

  // Stores this deployment's own state in the Snap CD State Store instead of a
  // local terraform.tfstate file. The defaults below match the pre-configured
  // "snapcd-selfhosted-deployment-docker" setup (like the defaults in
  // variables.tf): the URL path is
  // /api/{organizationId}/state/{stateStoreId}/{stateFileName}, username is
  // the client id and password is the client secret. Both the seeded organization
  // and the seeded "default" State Store use the fixed ID
  // 10000000-0000-0000-0000-000000000000, which is why it appears twice below.
  //
  // Backend blocks cannot reference variables. To point at a different server or
  // credentials, override any of these at init time, e.g.:
  //
  //   tofu init \
  //     -backend-config="address=https://localhost:20002/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith" \
  //     -backend-config="lock_address=https://localhost:20002/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith/lock" \
  //     -backend-config="unlock_address=https://localhost:20002/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith/unlock" \
  //     -backend-config="username=default" \
  //     -backend-config="password=default"
  //
  // If your server uses a self-signed certificate, also pass
  // -backend-config="skip_cert_verification=true".
  backend "http" {
    # address        = "http://localhost:5000/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith"
    # lock_address   = "http://localhost:5000/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith/lock"
    # unlock_address = "http://localhost:5000/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith/unlock"

    address        = "https://localhost:20002/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith"
    lock_address   = "https://localhost:20002/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith/lock"
    unlock_address = "https://localhost:20002/api/10000000-0000-0000-0000-000000000000/state/10000000-0000-0000-0000-000000000000/sample-deployment-demonolith/unlock"

    lock_method            = "POST"
    unlock_method          = "POST"
    username               = "default"
    password               = "default"
    skip_cert_verification = true
  }
}
