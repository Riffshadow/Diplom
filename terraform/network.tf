resource "yandex_vpc_network" "diplom" {
  name = "diplom-network"
}

resource "yandex_vpc_gateway" "nat" {
  name = "diplom-nat"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "diplom-private-routes"
  network_id = yandex_vpc_network.diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "public" {
  for_each = {
    a = "10.10.1.0/24"
    b = "10.10.2.0/24"
  }

  name           = "diplom-public-${each.key}"
  zone           = "ru-central1-${each.key}"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = [each.value]
}

resource "yandex_vpc_subnet" "private" {
  for_each = {
    a = "10.10.11.0/24"
    b = "10.10.12.0/24"
  }

  name           = "diplom-private-${each.key}"
  zone           = "ru-central1-${each.key}"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = [each.value]
  route_table_id = yandex_vpc_route_table.private.id
}
