# Reference your existing GCP project
data "new-project-462710" "New Project" {
}

# Reference your existing Compute Engine instance
data "google_compute_instance" "existing_vm" {
  name     = "tamiri-candy"  # Replace with your actual VM name
  zone     = "us-central1-a"          # Replace with your VM's zone
}

# Use a null_resource with a remote-exec provisioner to install Docker
resource "null_resource" "install_docker" {
  # This ensures we only run after the VM exists
  triggers = {
    instance_id = data.google_compute_instance.existing_vm.id
  }

  connection {
    type        = "ssh"
    host        = data.google_compute_instance.existing_vm.network_interface[0].access_config[0].nat_ip
    user        = "ubuntu"  # Replace with your VM's username
    private_key = file("~/.ssh/your_private_key")  # Path to your SSH private key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ${data.google_compute_instance.existing_vm.metadata["ssh-username"]}"
    ]
  }
}
