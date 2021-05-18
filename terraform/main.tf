provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "app" {
  name         = "test-app-${count.index}"
  machine_type = "e2-micro"
  zone         = "europe-west1-b"
  tags         = ["puma-server"]
  count        = var.instance_count
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }
  metadata = {
	ssh-keys = "appuser:${file(var.public_key_path)}"
  }  
  network_interface {
    network = "default"
    access_config {}
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    host        = self.network_interface[0].access_config[0].nat_ip
    agent       = false
    private_key = file(var.private_key_path)
  }

}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  project = var.project
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["puma-server"]
}

resource "google_compute_project_metadata_item" "metadata" {
	key = "ssh-keys"
	value = join("\n", var.ssh_keys)
}
