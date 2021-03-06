resource "proxmox_vm_qemu" "kube-master" {
  for_each = var.masters

  name        = each.key
  target_node = var.common.target_node
  agent       = 1
  clone       = var.common.clone
  vmid        = each.value.id
  memory      = each.value.memory
  cores       = each.value.cores
  vga {
    type = "qxl"
  }
  network {
    id       = 0
    model    = "virtio"
    macaddr  = each.value.macaddr
    bridge   = "vmbr0"
    firewall = true
  }
  disk {
    id           = 0
    type         = "scsi"
    storage      = "local"
    storage_type = "dir"
    size         = each.value.disk
    format       = "qcow2"
  }
  serial {
    id   = 0
    type = "socket"
  }
  bootdisk   = "scsi0"
  scsihw     = "virtio-scsi-pci"
  os_type    = "cloud-init"
  ipconfig0  = "ip=${each.value.cidr},gw=${each.value.gw}"
  ciuser     = "terraform"
  cipassword = yamldecode(data.local_file.secrets.content).user_password # comment after creation
  # cipassword   = "**********" # un-comment after creation
  searchdomain = var.common.search_domain
  nameserver   = var.common.nameserver
  sshkeys = join("", [
    data.tls_public_key.dy2k.public_key_openssh,
    data.tls_public_key.ubuntu_terraform.public_key_openssh
  ])

  depends_on = [
    proxmox_lxc.gateway
  ]

  connection {
    host                = each.value.ip
    user                = "terraform"
    private_key         = data.tls_public_key.ubuntu_terraform.private_key_pem
    bastion_host        = var.common.bastion_host
    bastion_private_key = data.tls_public_key.dy2k.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo usermod --password $(openssl passwd -1 ${yamldecode(data.local_file.secrets.content).root_password}}) root",
      "ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N \"\"",
      "echo \"${data.tls_public_key.ubuntu_terraform.private_key_pem}\" > ~/.ssh/id_rsa",
      "echo \"${data.tls_public_key.ubuntu_terraform.public_key_openssh}\" > ~/.ssh/id_rsa.pub",
    ]
  }
}
