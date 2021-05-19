resource "google_compute_instance" "db" {
  name = "testapp-db"
  machine_type = "e2-micro"
  zone = "${var.zone}"
    tags = ["test-app-db"]
    boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
 }
}

resource "google_compute_firewall" "firewall_mongo" {
  name = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["27017"]
  }
  target_tags = ["test-app-db"]
  source_tags = ["puma-server"]
}

