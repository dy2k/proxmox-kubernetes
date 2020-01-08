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
  type = map(list(map(string)))
  default = {
    kube-master1 = [
      {

      }
    ],
    kube-master2 = [
      {

      }
    ]
  }
}

variable "workers" {
  type = map(list(map(string)))
  default = {
    kube-worker1 = [
      {

      }
    ],
    kube-worker2 = [
      {

      }
    ],
    kube-worker3 = [
      {

      }
    ]
  }
}
