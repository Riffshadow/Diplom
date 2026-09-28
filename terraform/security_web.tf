resource "yandex_vpc_security_group" "alb" {
  name       = "diplom-alb-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "Public HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "ALB health checks"
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "Traffic to backends"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["10.10.11.0/24", "10.10.12.0/24"]
  }
}

resource "yandex_vpc_security_group" "zabbix" {
  name       = "diplom-zabbix-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "Zabbix frontend public"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Active agents from managed servers"
    protocol          = "TCP"
    port              = 10051
    security_group_id = yandex_vpc_security_group.management.id
  }

  ingress {
    description       = "Active agent from bastion"
    protocol          = "TCP"
    port              = 10051
    security_group_id = yandex_vpc_security_group.bastion.id
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "diplom-web-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "HTTP from load balancer"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
  }

  ingress {
    description       = "HTTP checks from Zabbix"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.zabbix.id
  }
}
