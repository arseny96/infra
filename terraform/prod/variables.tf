variable "project" {
  description = "Project ID"
  default = "virtual-nimbus-313719"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone"
  default     = "europe-west1-b"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "ssh_keys" {
  description = "Path to the public keys used for ssh access"
}

variable "disk_image" {
  description = "Disk image"
}

variable "instance_count" {
  description = "Count of Instances" 
}

variable app_disk_image {
  description = "Disk image for test app"
  default = "testapp-base"
}

variable db_disk_image {
  description = "Disk image for test app db"
  default = "testapp-db-base"
}
