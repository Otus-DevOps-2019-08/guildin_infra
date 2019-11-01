resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {
    
    }
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
  }
#  resource "null_resource" "post-install" {
#  connection {
#    type        = "ssh"
#    host        = google_compute_instance.db.network_interface[0].access_config[0].nat_ip
#    user        = "appuser"
#    agent       = false
#    private_key = file(var.private_key_path)
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf",
#      "sudo service mongod restart",
#    ]
#  }
#
#}





