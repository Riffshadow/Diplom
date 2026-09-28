variable "admin_cidr" {
  description = "Внешний IPv4 администратора с маской /32"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Укажите один IPv4-адрес с маской /32."
  }
}

resource "yandex_vpc_security_group" "bastion" {
  name       = "diplom-bastion-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "SSH from administrator"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
  }

  egress {
    description    = "Outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "management" {
  name       = "diplom-management-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "SSH through bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "Outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
