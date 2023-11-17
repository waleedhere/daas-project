terraform {
  backend "s3" {
    bucket = ""
    key    = "eks/nonprod.tfstate"
    region = ""
  }
}

