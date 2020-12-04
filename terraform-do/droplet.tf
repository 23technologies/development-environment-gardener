# for an already existing key:
# doctl compute ssh-key list
# terraform import digitalocean_ssh_key.default <ID>
resource "digitalocean_ssh_key" "default" {
  name       = "terraform"
  public_key = file("~/.ssh/id_rsa.pub")
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name
    ]
  }
}


resource "digitalocean_droplet" "dev" {
  image    = "ubuntu-20-04-x64"
  name     = "garden-development"
  region   = "fra1"
  size     = "s-4vcpu-8gb"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  connection {
    host    = self.ipv4_address
    user    = "root"
    type    = "ssh"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "../start.sh"
    destination = "/tmp/start.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/start.sh",
      "/tmp/start.sh",
    ]
  }
}

output "ip" {
  value = digitalocean_droplet.dev.ipv4_address
}