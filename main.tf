provider "aws" {
  region = "eu-west-1"  # Set your desired AWS region here
  default_tags {
    tags = {
      CreatedBy = "Mayur Hastak"
      Project   = "PortForwaring Demo"
    }
  }
}



