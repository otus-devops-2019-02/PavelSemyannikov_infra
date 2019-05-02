resource "google_compute_forwarding_rule" "reddit-app" {
  name       = "reddit-app"
  target     = "${google_compute_target_pool.reddit-app.self_link}"
  port_range = "9292"
}

resource "google_compute_target_pool" "reddit-app" {
  name = "reddit-app"

  instances = [
    "${google_compute_instance.app.0.self_link}",
    "${google_compute_instance.app.1.self_link}",
    "${google_compute_instance.app.2.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.reddit-app.self_link}",
  ]
}

resource "google_compute_http_health_check" "reddit-app" {
  name               = "reddit-app"
  port               = 9292
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
