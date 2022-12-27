terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.84"

  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "alex-rybalko-k0s-infra-tfstate"
    region   = "ru-central1"
    key      = "infra.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

data "yandex_resourcemanager_folder" "k0s" {
  name = "k0s"
}
