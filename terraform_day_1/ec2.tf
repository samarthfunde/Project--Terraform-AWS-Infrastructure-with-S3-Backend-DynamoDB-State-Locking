# key pair (login)

resource "aws_key_pair" "my-key" {   
  # my-key = identifier of resource block
  key_name   = "terr-key-ec2"
  public_key = file("terr-key-ec2.pub")
}

# VPC & Security Group

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "my-sg" {
  name        = "automate-sg"
  description = "this will add a TF generated Security group"

  # interpolation = extract value from terraform block
  vpc_id = aws_default_vpc.default.id    

  tags = {
    Name = "automate-security grp"
  }

  # Inbound Rules
  # 1) For SSH Login open port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    description = "HTTP Open"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "app"
  }

  # Outbound Rules - traffic going outside from instance
  egress {
    from_port   = 0      # 0 means all ports
    to_port     = 0      # 0 means all ports
    protocol    = "-1"   # all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access open outbound"
  }
}

# EC2 Instance

resource "aws_instance" "my-instance" {

  # interpolation
  key_name = aws_key_pair.my-key.key_name  

  # ALWAYS use vpc_security_group_ids with SG ID
  vpc_security_group_ids = [aws_security_group.my-sg.id]

  instance_type = "t2.micro"
  ami           = "ami-02b8269d5e85954ef" # ubuntu machine

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "CWS-Instance"
  }
}
