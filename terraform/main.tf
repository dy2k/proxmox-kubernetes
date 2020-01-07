provider "proxmox" {
  pm_tls_insecure = true
}

provider "tls" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}
