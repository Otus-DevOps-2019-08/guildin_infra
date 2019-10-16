resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-fwd-rule"
  project    = var.project
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "http-proxy"
  url_map = "${google_compute_url_map.default.self_link}"

}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"

  host_rule {
    hosts        = ["*"]
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
  name = "backend-service"
  backend {
    group = "${google_compute_instance_group.default.self_link}"
  }
  health_checks = ["${google_compute_http_health_check.default.self_link}"]

}

resource "google_compute_http_health_check" "default" {
  name = "http-health-check"

  port = "9292"
}


resource "google_compute_instance_group" "default" {
  name        = "terraform-webservers"
  description = "Terraform test instance group"
  zone        = var.zone
  instances   = "${google_compute_instance.app[*].self_link}"

  named_port {
    name = "http"
    port = "9292"
  }
}

resource "google_compute_health_check" "default" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "9292"
  }
}
