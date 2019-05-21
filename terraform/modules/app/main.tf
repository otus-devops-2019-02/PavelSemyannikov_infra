resource "google_compute_instance" "app" {
  name         = "${var.infra_prefix}-reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.infra_prefix}-reddit-app", "${var.infra_prefix}-allow-ssh", "${var.infra_prefix}-nginx"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  #connection {
  #  type        = "ssh"
  #  user        = "appuser"
  #  agent       = false
  #  private_key = "${file("${var.private_key_path}")}"
  #}

  #provisioner "local-exec" {
  #  command = "sed -i 's/.*Environment=DATABASE_URL.*/Environment=DATABASE_URL=${var.db_internal_ip}:27017/' ../modules/app/files/puma.service"
  #}

  #provisioner "file" {
  #  source      = "../modules/app/files/puma.service"
  #  destination = "/tmp/puma.service"
  #}

  #provisioner "remote-exec" {
  #  script = "../modules/app/files/deploy.sh"
  #}
}

resource "google_compute_address" "app_ip" {
  name = "${var.infra_prefix}-reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "${var.infra_prefix}-allow-puma"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.infra_prefix}-reddit-app"]
}

resource "google_compute_firewall" "firewall_nginx" {
  name    = "${var.infra_prefix}-allow-nginx"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.infra_prefix}-nginx"]
}
