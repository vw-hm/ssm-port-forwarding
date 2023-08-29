locals {

    user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y > /home/ec2-user/httpd_log.txt
    sudo yum install httpd -y >> /home/ec2-user/httpd_log.txt
    sudo service httpd start >> /home/ec2-user/httpd_log.txt
    sudo chkconfig httpd on >> /home/ec2-user/httpd_log.txt
    sudo service httpd status >> /home/ec2-user/httpd_log.txt
    sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm >> /home/ec2-user/httpd_log.txt
    sudo systemctl status amazon-ssm-agent >> /home/ec2-user/httpd_log.txt
  EOT
}


module "public_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "public-instance"

  instance_type          = "t2.micro"
  key_name               = "Mayur_PrivateKeyPair"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.example_security_group.id]
  subnet_id              = aws_subnet.example_subnet.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "example_security_group" {
  name        = "Mayur-SSH-SecGrp"
  description = "Example security group"
  vpc_id = aws_vpc.example_vpc.id

  // Ingress rule to allow SSH from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

}

module "private_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  count = 1

  name = "private-instance"

  instance_type          = "t2.micro"
  key_name               = "Mayur_PrivateKeyPair"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.private_instance_security_group.id]
  subnet_id              = aws_subnet.example_private_subnet.id
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    SSMPolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "private_instance_security_group" {
  name        = "PrivateInstance-SecGrp"
  description = "Private Instance security group"
  vpc_id = aws_vpc.example_vpc.id

  // Ingress rule to allow SSH from any IP address
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${module.public_ec2_instance.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

}