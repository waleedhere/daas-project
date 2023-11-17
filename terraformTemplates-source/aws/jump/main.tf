module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "nonporod-bastion"
  ami                    = "ami-0d2a4a5d69e46ea0b"
  instance_type          = "t2.micro"
  key_name               = ""
  monitoring             = true
  vpc_security_group_ids = ["",""]
  subnet_id              = ""

  tags = {
    
  }
}


