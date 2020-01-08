data "local_file" "secrets" {
  filename = "./.terraform_secret.yaml"
}

data "tls_public_key" "dy2k" {
  private_key_pem = "${yamldecode(data.local_file.secrets.content).id_rsa}"
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
