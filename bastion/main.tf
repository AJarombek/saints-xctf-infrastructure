/**
 * Infrastructure for creating a bastion host to private subnet resources
 * Author: Andrew Jarombek
 * Date: 2/12/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/bastion"
    region = "us-east-1"
  }
}

data "aws_subnet" "saints-xctf-public-subnet-1" {
  tags {
    Name = "SaintsXCTFcom VPC Public Subnet 1"
  }
}

resource "aws_instance" "bestion" {
  # Use Amazon Linux 2
  ami = "ami-035be7bafff33b6b6"

  instance_type = "t2.micro"
  subnet_id = "${data.aws_subnet.saints-xctf-public-subnet-1.id}"

  network_interface {
    device_index = 0
    network_interface_id = ""
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_network_interface" "bastion-network-interface" {
  subnet_id = "${data.aws_subnet.saints-xctf-public-subnet-1.id}"
  description = "Network Interface for the Bastion Host"
  private_ips = ["10.0.2.0"]
  private_ips_count = 1
  security_groups = [""]

  attachment {
    device_index = 0
    instance = "${aws_instance.bestion.id}"
  }
  
  tags {
    Name = "Network Interface for the Bastion Host"
  }
}