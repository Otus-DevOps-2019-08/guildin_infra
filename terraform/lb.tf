resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-rule"
  project = var.project
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "test-proxy"
  url_map = "${google_compute_url_map.default.self_link}"

}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"

  host_rule {
    hosts        = [google_compute_instance.app.network_interface[0].access_config[0].nat_ip, google_compute_instance.app2.network_interface[0].access_config[0].nat_ip]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.default.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.default.self_link}"
    }
  }

}

resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = ["${google_compute_http_health_check.default.self_link}"]

}

resource "google_compute_http_health_check" "default" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_instance_group_manager" "default" {
  name = "appserver-igm"
  base_instance_name = "igm-basename"
  instance_template  = "${google_compute_instance_template.default.self_link}"  
  zone               = var.zone

  target_pools = ["${google_compute_target_pool.default.self_link}"]
  target_size  = 1

  named_port {
    name = "http"
    port = 9292
  }

auto_healing_policies {
    health_check      = "${google_compute_health_check.default.self_link}"
    initial_delay_sec = 300
  }

}

resource "google_compute_instance_template" "default" {
  name_prefix  = "instance-template-"
  machine_type = "f1-micro"
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }

  network_interface {
  network = "default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_pool" "default" {
  name = "load-balancer"

  instances = [
    "europe-west1-b/target-pool",
  ]

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}
resource "google_compute_health_check" "default" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10                         # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "9292"
  }
}
