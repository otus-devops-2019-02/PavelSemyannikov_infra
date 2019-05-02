variable infra_prefix {
  description = "Prefix for infra (stage, prod, etc)"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-db-base"
}
