terraform {
  #  required_version = "0.11.11"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  infra_prefix    = "${var.infra_prefix}"
  source          = "../modules/app"
  public_key_path = "${var.public_key_path}"

  #private_key_path = "${var.private_key_path}"
  zone           = "${var.zone}"
  app_disk_image = "${var.app_disk_image}"

  #db_internal_ip   = "${module.db.db_internal_ip}"
}

module "db" {
  infra_prefix    = "${var.infra_prefix}"
  source          = "../modules/db"
  public_key_path = "${var.public_key_path}"

  #private_key_path = "${var.private_key_path}"
  zone          = "${var.zone}"
  db_disk_image = "${var.db_disk_image}"
}

module "vpc" {
  infra_prefix  = "${var.infra_prefix}"
  source        = "../modules/vpc"
  source_ranges = ["178.170.172.113/32"]
}
