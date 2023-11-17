terraform {
  backend "s3" {
    bucket = ""
    key    = "ec2/bastion.tfstate"
    region = ""
    #encrypt = true
    #kms_key_id = "alias/terraform"
  }
}

