# for an already existing key:
# hcloud ssh-key list
# terraform import hcloud_ssh_key.default <ID>
resource "hcloud_ssh_key" "default" {
  name       = "terraform"
  public_key = file("~/.ssh/id_rsa.pub")
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name
    ]
  }
}


resource "hcloud_server" "dev" {
  name        = "dev"
  image       = "ubuntu-20.04"
  server_type = "cpx31"
  location    = "fsn1"
  ssh_keys    = [hcloud_ssh_key.default.id]

  connection {
    host    = self.ipv4_address
    user    = "root"
    type    = "ssh"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "../../start.sh"
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
  value = hcloud_server.dev.ipv4_address
}