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
