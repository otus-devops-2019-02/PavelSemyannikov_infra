variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable infra_prefix {
  description = "Prefix for infra (stage, prod, etc)"
}
