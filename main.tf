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

resource "vault_kv_secret_v2" "db-creds" {
  mount = vault_mount.bar.path
  name  = "db-creds"
  data_json = jsonencode(
    {
      user     = "postgres",
      password = "pg",
    }
  )
}

resource "vault_mount" "database" {
  path = "database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend = vault_mount.database.path
  name    = "postgres"
  allowed_roles = [
    "dev",
  ]

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@127.0.0.1:5432/postgres?sslmode=disable"
    username       = "postgres"
    password       = "pg"
  }
}

resource "vault_database_secret_backend_role" "postgres-dev" {
  backend             = vault_mount.database.path
  name                = "dev"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
}
