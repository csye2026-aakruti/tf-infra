resource "aws_key_pair" "main" {
  key_name   = "${var.project}-${var.env}-${var.name_suffix}-key"
  public_key = var.ssh_public_key
}