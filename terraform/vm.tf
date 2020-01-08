resource "proxmox_vm_qemu" "kube-master" {
  for_each = var.masters

  name        = each.key
  target_node = "proxmox"

  depends_on = [
    proxmox_lxc.gateway
  ]
}

resource "proxmox_vm_qemu" "kube-worker" {
  for_each = var.workers

  name        = each.key
  target_node = "proxmox"

  depends_on = [
    proxmox_vm_qemu.kube-master
  ]
}
