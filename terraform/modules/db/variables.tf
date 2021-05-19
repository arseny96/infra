variable "zone" {
 description = "Zone"
  default     = "europe-west1-b"
}

variable db_disk_image {
  description = "Disk image for test app db"
  default = "testapp-db-base"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
  default = "~/.ssh/appuser.pub"
}
