resource "google_compute_forwarding_rule" "default" {
  name       = "test-app-lb-forwarding-rule"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = 9292
}

resource "google_compute_target_pool" "default" {
  name = "test-app-lb-target-pool"

  instances = [
    for item in google_compute_instance.app : item.self_link
  ]

  health_checks = [
    "${google_compute_http_health_check.test-app.name}",
  ]
}

resource "google_compute_http_health_check" "test-app" {
  name               = "test-app-http-health-check"
  port               = "9292"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
