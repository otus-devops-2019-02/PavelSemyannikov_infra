output "app0_external_ip" {
  value = "${google_compute_instance.app.0.network_interface.0.access_config.0.nat_ip}"
}

output "app1_external_ip" {
  value = "${google_compute_instance.app.1.network_interface.0.access_config.0.nat_ip}"
}

output "app2_external_ip" {
  value = "${google_compute_instance.app.2.network_interface.0.access_config.0.nat_ip}"
}

output "balancer_external_ip" {
  value = "${google_compute_forwarding_rule.reddit-app.ip_address}"
}
