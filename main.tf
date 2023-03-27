terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.14.0"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root"
}

resource "vault_mount" "foo" {
  path    = "foo"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_mount" "bar" {
  path = "bar"
  type = "kv-v2"
}
