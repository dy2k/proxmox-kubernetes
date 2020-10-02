terraform {
  backend "s3" {
    bucket  = "proxmox-kubernetes"
    key     = "terraform/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "dy2k"
    encrypt = true
  }

  required_providers {
    proxmox = {
      source  = "ondrejsika/proxmox"
      version = "2020.9.21"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = yamldecode(data.local_file.secrets.content).pm_api_url
  pm_user         = yamldecode(data.local_file.secrets.content).pm_user
  pm_password     = yamldecode(data.local_file.secrets.content).pm_password
}

provider "tls" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

provider "local" {
  version = "~> 1.4"
}
