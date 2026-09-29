resource "yandex_vpc_security_group" "kibana" {
  name       = "diplom-kibana-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "Kibana frontend from administrator"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Filebeat dashboard setup"
    protocol          = "TCP"
    port              = 5601
    security_group_id = yandex_vpc_security_group.web.id
  }
}

resource "yandex_vpc_security_group" "elasticsearch" {
  name       = "diplom-elasticsearch-sg"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "Logs from web servers"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    description       = "Queries from Kibana"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }
}
