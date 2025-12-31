resource "aws_instance" "sonar" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name 
  vpc_security_group_ids = var.security_group_ids
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }
  tags = {
    Name = "sonar-server"
  }
}


