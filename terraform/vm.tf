resource "proxmox_vm_qemu" "kube-master1" {
  depends_on = [
    "proxmox_lxc.gateway1",
    "proxmox_lxc.gateway2"
  ]
}

resource "proxmox_vm_qemu" "kube-master2" {
  depends_on = [
    "proxmox_lxc.gateway1",
    "proxmox_lxc.gateway2"
  ]
}

resource "proxmox_vm_qemu" "kube-worker1" {
  depends_on = [
    "proxmox_vm_qemu.master1",
    "proxmox_vm_qemu.master2"
  ]
}

resource "proxmox_vm_qemu" "kube-worker2" {
  depends_on = [
    "proxmox_vm_qemu.master1",
    "proxmox_vm_qemu.master2"
  ]
}

resource "proxmox_vm_qemu" "kube-worker3" {
  depends_on = [
    "proxmox_vm_qemu.master1",
    "proxmox_vm_qemu.master2"
  ]
}

