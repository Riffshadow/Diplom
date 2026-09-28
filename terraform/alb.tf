resource "yandex_alb_target_group" "web" {
  name = "diplom-web-targets"

  dynamic "target" {
    for_each = toset(["web-1", "web-2"])

    content {
      subnet_id  = yandex_compute_instance.vm[target.value].network_interface[0].subnet_id
      ip_address = yandex_compute_instance.vm[target.value].network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "diplom-web-backends"

  http_backend {
    name             = "nginx"
    port             = 80
    weight           = 1
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      healthcheck_port    = 80
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "diplom-http-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "diplom-website"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "all-pages"

    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }

      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "diplom-alb"
  network_id         = yandex_vpc_network.diplom.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    dynamic "location" {
      for_each = yandex_vpc_subnet.public

      content {
        zone_id   = location.value.zone
        subnet_id = location.value.id
      }
    }
  }

  auto_scale_policy {
    min_zone_size = 2
    max_size      = 4
  }

  listener {
    name = "http"

    endpoint {
      ports = [80]

      address {
        external_ipv4_address {}
      }
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }

  log_options {
    disable = true
  }

  depends_on = [yandex_alb_virtual_host.web]
}
