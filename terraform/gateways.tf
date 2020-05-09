resource "proxmox_lxc" "gateway" {
  for_each = var.gateways

  ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz" # comment after creation
  #   ostype     = "ubuntu" # un-comment after creation
  cores      = 2
  hostname   = each.key
  memory     = 2048
  nameserver = "10.0.0.1"
  dynamic "network" {
    for_each = each.value

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
  password = random_password.ubuntu_root.result # comment after creation
  rootfs   = "local:16"                         # comment after creation
  #   rootfs       = "local:103/vm-103-disk-0.raw,size=16G" # un-comment after creation
  searchdomain = "sd-51798.dy2k.io"
  ssh_public_keys = join("", [                      # comment after creation
    data.tls_public_key.dy2k.public_key_openssh,    # comment after creation
    tls_private_key.ubuntu_dyung.public_key_openssh # comment after creation
  ])                                                # comment after creation
  start = true                                      # comment after creation
  #   start        = false # un-comment after creation
  unprivileged = true
  target_node  = "sd-51798"

  connection {
    host                = each.value[0].ip
    private_key         = tls_private_key.ubuntu_dyung.private_key_pem
    bastion_host        = "ubuntu.dy2k.io"
    bastion_private_key = data.tls_public_key.dy2k.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N \"\"",
      "echo \"${tls_private_key.ubuntu_root.private_key_pem}\" > /root/.ssh/id_rsa",
      "echo \"${tls_private_key.ubuntu_root.public_key_openssh}\" > /root/.ssh/id_rsa.pub",
      "echo \"${tls_private_key.ubuntu_root.public_key_openssh}\" >> /root/.ssh/authorized_keys",
      "adduser --disabled-password --gecos \"\" dyung && usermod -aG sudo dyung",
      "su - dyung -c 'ssh-keygen -b 2048 -t rsa -f /home/dyung/.ssh/id_rsa -q -N \"\"'",
      "su - dyung -c 'echo \"${tls_private_key.ubuntu_dyung.private_key_pem}\" > /home/dyung/.ssh/id_rsa'",
      "su - dyung -c 'echo \"${tls_private_key.ubuntu_dyung.public_key_openssh}\" > /home/dyung/.ssh/id_rsa.pub'",
      "su - dyung -c 'echo \"${tls_private_key.ubuntu_dyung.public_key_openssh}\" > /home/dyung/.ssh/authorized_keys'",
      "su - dyung -c 'echo \"${data.tls_public_key.dy2k.public_key_openssh}\" >> /home/dyung/.ssh/authorized_keys'",
      "chmod 700 /home/dyung/.ssh/authorized_keys"
    ]
  }
}
