terraform {
  required_version = ">= 0.13.1"

  required_providers {
    azurearm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}

