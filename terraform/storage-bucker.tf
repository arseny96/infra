provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}
module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.1"
  # Имена поменяйте на другие
  name = "storage-bucket-apptest1"
}
output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
