resource "aws_instance" "sonar" {
  ami           = var.ami_id
  instance_type = var.instance_type
  ebs_optimized = true
  key_name      = var.key_name 
  iam_instance_profile = "test"
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = false
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted  = true

    tags = {
        Environment = "Dev"
        Service = "ebs"
    }
  
  }
  monitoring = true
  metadata_options {
        
      http_endpoint = "enabled"
      http_tokens   = "required"
 }
  tags = {
    Name = "sonar-server"
    Environment = "Dev"
    Service = "EC2"
  }
}


