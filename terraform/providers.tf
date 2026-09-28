terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  folder_id = "b1g18jmeqan3jmvf8943"
  zone      = "ru-central1-a"
}
