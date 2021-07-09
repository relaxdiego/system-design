resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from the Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "SSH to VPC instances"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
}


resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet1.id
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
}
