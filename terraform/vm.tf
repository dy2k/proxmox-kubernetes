resource "proxmox_vm_qemu" "kube-cluster" {
  for_each = var.masters

  name        = each.key
  target_node = "proxmox"
  agent       = 1
  iso         = "local:iso/ubuntu-18.04.3-live-server-amd64.iso"
  memory      = each.value.memory
  cores       = each.value.cores
  vga {
    type = "std"
  }
  network {
    id       = 0
    model    = "virtio"
    macaddr  = each.value.macaddr
    bridge   = "vmbr1"
    firewall = true
  }
  disk {
    id           = 0
    type         = "scsi"
    storage      = "local"
    storage_type = "lvm"
    size         = "80G"
    format       = "qcow2"
  }
  serial {
    id   = 0
    type = "socket"
  }
  os_type      = "ubuntu"
  ipconfig0    = "ip=${each.value.cidr},gw=${each.value.gw}"
  ciuser       = "root"
  cipassword   = random_password.ubuntu_root.result
  searchdomain = "sd-51798.dy2k.io"
  nameserver   = "10.0.0.1"
  sshkeys = join("", [
    data.tls_public_key.dy2k.public_key_openssh,
    tls_private_key.ubuntu_dyung.public_key_openssh
  ])

  depends_on = [
    proxmox_lxc.gateway
  ]

  connection {
    host                = each.value.ip
    private_key         = tls_private_key.ubuntu_dyung.private_key_pem
    bastion_host        = "ubuntu.dy2k.io"
    bastion_private_key = data.tls_public_key.dy2k.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N \"\"",
      "echo \"${tls_private_key.ubuntu_root.private_key_pem}\" > /root/.ssh/id_rsa",
      "echo \"${tls_private_key.ubuntu_root.public_key_pem}\" > /root/.ssh/id_rsa.pub",
      "echo \"${tls_private_key.ubuntu_root.public_key_openssh}\" >> /root/.ssh/authorized_keys",
      "adduser --disabled-password --gecos \"\" dyung && usermod -aG sudo dyung",
      "su - dyung -c 'ssh-keygen -b 2048 -t rsa -f /home/dyung/.ssh/id_rsa -q -N \"\"'",
      "su - dyung -c 'echo \"${tls_private_key.ubuntu_dyung.private_key_pem}\" > /home/dyung/.ssh/id_rsa'",
      "su - dyung -c 'echo \"${tls_private_key.ubuntu_dyung.public_key_pem}\" > /home/dyung/.ssh/id_rsa.pub'",
      "su - dyung -c 'echo \"${tls_private_key.ubuntu_dyung.public_key_openssh}\" > /home/dyung/.ssh/authorized_keys'",
      "su - dyung -c 'echo \"${data.tls_public_key.dy2k.public_key_openssh}\" >> /home/dyung/.ssh/authorized_keys'",
      "chmod 700 /home/dyung/.ssh/authorized_keys"
    ]
  }
}
