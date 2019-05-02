resource "google_compute_firewall" "firewall_ssh" {
  name        = "${var.infra_prefix}-allow-ssh"
  network     = "default"
  description = "SSH access"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
  target_tags   = ["${var.infra_prefix}-allow-ssh"]
}
