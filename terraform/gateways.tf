resource "proxmox_lxc" "gateway" {
  for_each = var.gateways

  ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz" # comment after creation
  ostype     = "ubuntu"
  cores      = 2
  hostname   = each.key
  vmid       = each.value.id
  memory     = 2048
  dynamic "network" {
    for_each = each.value.network

    content {
      name     = network.value.name
      bridge   = "vmbr0"
      firewall = true
      gw       = network.value.gw
      hwaddr   = network.value.hwaddr
      ip       = network.value.cidr
      rate     = 0
      tag      = 0
      type     = "veth"
    }
  }
  swap     = 2048
  onboot   = true
  password = yamldecode(data.local_file.secrets.content).root_password # comment after creation
  rootfs   = "local:${each.value.disk},size=${each.value.disk}G"       # comment after creation
  # rootfs   = "local:${each.value.id}/vm-${each.value.id}-disk-0.raw,size=${each.value.disk}G" # un-comment after creation
  searchdomain = "sd-51798.dy2k.io"
  ssh_public_keys = join("", [                              # comment after creation
    data.tls_public_key.dy2k.public_key_openssh,            # comment after creation
    data.tls_public_key.ubuntu_terraform.public_key_openssh # comment after creation
  ])                                                        # comment after creation
  start = true                                              # comment after creation
  #   start        = false # un-comment after creation
  unprivileged = true
  target_node  = "sd-51798"

  connection {
    host                = each.value.network[0].ip
    private_key         = data.tls_public_key.ubuntu_terraform.private_key_pem
    bastion_host        = "ubuntu.dy2k.io"
    bastion_private_key = data.tls_public_key.dy2k.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "adduser --disabled-password --gecos \"\" terraform && usermod -aG sudo terraform",
      "usermod --password $(openssl passwd -1 ${yamldecode(data.local_file.secrets.content).user_password}}) terraform",
      "echo 'terraform ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/terraform && chmod 440 /etc/sudoers.d/terraform",
      "su - terraform -c 'ssh-keygen -b 2048 -t rsa -f /home/terraform/.ssh/id_rsa -q -N \"\"'",
      "echo \"${data.tls_public_key.ubuntu_terraform.private_key_pem}\" > /home/terraform/.ssh/id_rsa",
      "echo \"${data.tls_public_key.ubuntu_terraform.public_key_openssh}\" > /home/terraform/.ssh/id_rsa.pub",
      "echo \"${data.tls_public_key.ubuntu_terraform.public_key_openssh}\" >> /home/terraform/.ssh/authorized_keys",
      "echo \"${data.tls_public_key.dy2k.public_key_openssh}\" >> /home/terraform/.ssh/authorized_keys",
      "chown terraform:terraform /home/terraform/.ssh/authorized_keys && chmod 700 /home/terraform/.ssh/authorized_keys"
    ]
  }
}
