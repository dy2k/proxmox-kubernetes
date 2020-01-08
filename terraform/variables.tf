variable "gateways" {
  type = map(list(map(string)))
  default = {
    gateway1 = [
      {
        cidr   = "10.0.0.1/24"
        name   = "eth1"
        gw     = ""
        hwaddr = "06:08:72:DD:89:B4"
        ip     = "10.0.0.1"
      },
      {
        cidr   = "163.172.118.179/32"
        name   = "eth0"
        gw     = "62.210.0.1"
        hwaddr = "52:54:00:00:bc:0b"
      }
    ],
    gateway2 = [
      {
        cidr   = "10.0.0.2/24"
        name   = "eth0"
        gw     = ""
        hwaddr = "E6:48:8F:0C:D0:57"
        ip     = "10.0.0.2"
      }
    ]
  }
}

variable "masters" {
  type = map(map(string))
  default = {
    kube-master1 = {
      cidr    = "10.0.0.11/24"
      cores   = 2
      gw      = "10.0.0.1"
      macaddr = "6E:DE:EE:62:37:1D"
      ip      = "10.0.0.11"
      memory  = 2048
    },
    kube-master2 = {
      cidr    = "10.0.0.12/24"
      cores   = 2
      gw      = "10.0.0.1"
      macaddr = "2E:6E:FC:F0:A1:CB"
      ip      = "10.0.0.12"
      memory  = 2048
    }
  }
}

variable "workers" {
  type = map(map(string))
  default = {
    kube-worker1 = {
      cidr    = "10.0.0.21/24"
      cores   = 4
      gw      = "10.0.0.1"
      macaddr = "62:0E:E4:E4:7B:46"
      ip      = "10.0.0.21"
      memory  = 4096
    },
    kube-worker2 = {
      cidr    = "10.0.0.22/24"
      cores   = 4
      gw      = "10.0.0.1"
      macaddr = "5A:B1:D9:D1:E6:35"
      ip      = "10.0.0.22"
      memory  = 4096
    },
    kube-worker3 = {
      cidr    = "10.0.0.23/24"
      cores   = 4
      gw      = "10.0.0.1"
      macaddr = "22:92:5D:6B:7F:A1"
      ip      = "10.0.0.23"
      memory  = 4096
    },
  }
}
