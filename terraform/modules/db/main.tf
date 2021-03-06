resource "google_compute_instance" "db" {
  name         = "${var.infra_prefix}-reddit-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.infra_prefix}-reddit-db", "${var.infra_prefix}-allow-ssh"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
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

  #provisioner "file" {
  #  source      = "../modules/db/files/mongod.conf"
  #  destination = "/tmp/mongod.conf"
  #}

  #provisioner "remote-exec" {
  #  script = "../modules/db/files/deploy.sh"
  #}
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "${var.infra_prefix}-allow-mongo"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["${var.infra_prefix}-reddit-db"]
  source_tags = ["${var.infra_prefix}-reddit-app"]
}
