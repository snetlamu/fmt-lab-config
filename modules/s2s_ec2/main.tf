# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = var.inside_subnet_id
  private_ip                  = var.private_ip
  vpc_security_group_ids      = [var.sg_id]
  key_name                    = var.key_name

  tags = {
    Name = "${var.name}-s2s-instance-1"
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}