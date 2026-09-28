locals {
  servers = {
    bastion = {
      zone = "a", public = true, memory = 2, disk = 10
      ip   = "10.10.1.10"
    }
    web-1 = {
      zone = "a", public = false, memory = 2, disk = 10
      ip   = "10.10.11.10"
    }
    web-2 = {
      zone = "b", public = false, memory = 2, disk = 10
      ip   = "10.10.12.10"
    }
    zabbix = {
      zone = "a", public = true, memory = 4, disk = 10
      ip   = "10.10.1.20"
    }
    elasticsearch = {
      zone = "a", public = false, memory = 4, disk = 20
      ip   = "10.10.11.20"
    }
    kibana = {
      zone = "a", public = true, memory = 4, disk = 20
      ip   = "10.10.1.30"
    }
  }

  server_security_groups = {
    bastion = [
      yandex_vpc_security_group.bastion.id
    ]
    web-1 = [
      yandex_vpc_security_group.management.id,
      yandex_vpc_security_group.web.id
    ]
    web-2 = [
      yandex_vpc_security_group.management.id,
      yandex_vpc_security_group.web.id
    ]
    zabbix = [
      yandex_vpc_security_group.management.id,
      yandex_vpc_security_group.zabbix.id
    ]
    elasticsearch = [
      yandex_vpc_security_group.management.id,
      yandex_vpc_security_group.elasticsearch.id
    ]
    kibana = [
      yandex_vpc_security_group.management.id,
      yandex_vpc_security_group.kibana.id
    ]
  }
}

resource "yandex_compute_instance" "vm" {
  for_each = local.servers

  name                      = "diplom-${each.key}"
  hostname                  = "diplom-${each.key}"
  zone                      = "ru-central1-${each.value.zone}"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    core_fraction = 20
    memory        = each.value.memory
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      name     = "diplom-${each.key}-disk"
      image_id = var.image_id
      type     = "network-hdd"
      size     = each.value.disk
    }
  }

  network_interface {
    subnet_id = each.value.public ? (
      yandex_vpc_subnet.public[each.value.zone].id
    ) : yandex_vpc_subnet.private[each.value.zone].id

    ip_address         = each.value.ip
    nat                = each.value.public
    security_group_ids = local.server_security_groups[each.key]
  }

  metadata = {
    user-data = "#cloud-config\n${yamlencode({
      ssh_pwauth   = false
      disable_root = true
      users = [{
        name                = "ubuntu"
        shell               = "/bin/bash"
        groups              = ["sudo"]
        sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
        lock_passwd         = true
        ssh_authorized_keys = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
      }]
    })}"
  }
}
