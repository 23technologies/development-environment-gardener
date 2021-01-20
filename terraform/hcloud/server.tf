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

resource "random_id" "dev" {
  byte_length = 2
}

resource "hcloud_server" "dev" {
  name        = "dev-${random_id.dev.dec}"
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


}

resource "hcloud_volume" "dev" {
  name = "dev-${random_id.dev.dec}"
  location = "fsn1"
  size     = 10
  format   = "ext4"
}

resource "hcloud_volume_attachment" "dev" {
  volume_id = hcloud_volume.dev.id
  server_id = hcloud_server.dev.id
  automount = true

    provisioner "remote-exec" {
          connection {
      host     = hcloud_server.dev.ipv4_address
      user     = "root"
      type     = "ssh"
      timeout  = "2m"
    }
    inline = [
      "chmod +x /tmp/start.sh",
      "/tmp/start.sh /mnt/HC_Volume_${hcloud_volume.dev.id}",
    ]
  }
}

output "ip" {
  value = hcloud_server.dev.ipv4_address
}