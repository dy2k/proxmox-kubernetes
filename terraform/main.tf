provider "proxmox" {
  pm_tls_insecure = true
}

provider "tls" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

data "tls_public_key" "dy2k" {
  private_key_pem = "${file("./id_rsa")}"
}

resource "random_password" "ubuntu_root" {
  length = 24
}

resource "tls_private_key" "ubuntu_root" {
  algorithm = "RSA"
}

resource "tls_private_key" "ubuntu_dyung" {
  algorithm = "RSA"
}

resource "proxmox_lxc" "gateway1" {
  ostemplate = "local:vztmpl/ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz" # comment after creation
  #   ostype     = "ubuntu" # un-comment after creation
  cores      = 2
  hostname   = "gateway1"
  memory     = 2048
  nameserver = "10.0.0.1"
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    gw       = "62.210.0.1"
    hwaddr   = "52:54:00:00:bc:0b"
    ip       = "163.172.118.179/32"
    rate     = 0
    tag      = 0
    type     = "veth"
  }
  network {
    name     = "eth1"
    bridge   = "vmbr0"
    firewall = true
    hwaddr   = "06:08:72:DD:89:B4"
    ip       = "10.0.0.1/24"
    rate     = 0
    tag      = 0
    type     = "veth"
  }
  swap     = 2048
  onboot   = true
  password = "${random_password.ubuntu_root.result}" # comment after creation
  rootfs   = "local:16"                              # comment after creation
  #   rootfs       = "local:103/vm-103-disk-0.raw,size=16G" # un-comment after creation
  searchdomain    = "sd-51798.dy2k.io"
  ssh_public_keys = "${data.tls_public_key.dy2k.public_key_openssh}" # comment after creation
  start           = true                                             # comment after creation
  #   start        = false # un-comment after creation
  unprivileged = true
  target_node  = "proxmox"

  connection {
    host        = "ubuntu.dy2k.io"
    private_key = "${data.tls_public_key.dy2k.private_key_pem}"
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

resource "proxmox_lxc" "gateway2" {
  ostemplate = "local:vztmpl/ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz" # comment after creation
  #   ostype     = "ubuntu" # un-comment after creation
  cores      = 2
  hostname   = "gateway2"
  memory     = 2048
  nameserver = "10.0.0.1"
  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    hwaddr   = "E6:48:8F:0C:D0:57"
    ip       = "10.0.0.2/24"
    rate     = 0
    tag      = 0
    type     = "veth"
  }
  swap     = 2048
  onboot   = true
  password = "${random_password.ubuntu_root.result}" # comment after creation
  rootfs   = "local:16"                              # comment after creation
  #   rootfs       = "local:100/vm-100-disk-0.raw,size=16G" # un-comment after creation
  searchdomain    = "sd-51798.dy2k.io"
  ssh_public_keys = "${tls_private_key.ubuntu_dyung.public_key_openssh}" # comment after creation
  start           = true                                                 # comment after creation
  #   start        = false # un-comment after creation
  unprivileged = true
  target_node  = "proxmox"

  depends_on = [
    "proxmox_lxc.gateway1"
  ]

  connection {
    host                = "10.0.0.2"
    private_key         = "${tls_private_key.ubuntu_dyung.private_key_pem}"
    bastion_host        = "ubuntu.dy2k.io"
    bastion_private_key = "${data.tls_public_key.dy2k.private_key_pem}"
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
