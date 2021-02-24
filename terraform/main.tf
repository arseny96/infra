provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "e2-micro"
  zone         = "europe-west1-b"
  tags         = ["reddit-app"]
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
    host        = google_compute_instance.app.network_interface.0.access_config.0.nat_ip
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_project_metadata_item" "metadata" {
	key = "ssh-keys"
	value = "vbn:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXVx/Xuii7c/MkJaNJnCQXbSufH6GS2m05XYxIErWAZ0D2Q+2xOddOaW9LLEtTsnBvbfjI1CsULLgCrUWvormdmi1c8hepS2ZWtCaGti1hIEwRPo0EeBnuHRqxQ21dgLSICu/xj102tVVt7/dPQt/DSSLcYMKgNUsLvKow0CNQIpyUsOOIEivINSJGn5qDSsxYUEhYsr6mYgNAYIOWjb22CgE/wkRkcolKOZtK60D6COV+3gIkMZWAaoUG5+EBkfU7ZAWYIf7RZxTlpZDXgOcpnTvCm3zUN3GOiUVVWy8VkO3wdTelBYrQLZpOqS+jqPuegEV7l5ZlTDKFiZX03MsrdXgkAculFtF9h2KVJoHkYje2IJkltTrmgpOr9PQgGFlOr8sw9XaWyXDxW75KBjAtkXNu5/hLVH7iyFCnNw/+Xl/upd0cEExIRziGnE2ICmZ218zxgrfNjG2cI6Y2dF7SwpmHTXj47ubPlHOpSyw6fMXJ/wJM0dMm1Yb6fNCMD2c= vbn"
}
