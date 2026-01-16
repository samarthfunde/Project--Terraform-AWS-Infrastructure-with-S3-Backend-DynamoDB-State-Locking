# 1 key pair (login)

resource "aws_key_pair" "my-key" {
  # my-key = identifier of resource block
  key_name   = "terr-key-ec2"
  public_key = file("terr-key-ec2.pub")
}

# 2 VPC terraform init -upgrade

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# 3 Security Group
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
    from_port   = 0    # 0 means all ports
    to_port     = 0    # 0 means all ports
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access open outbound"
  }
}

# 4 EC2 Instance

resource "aws_instance" "my-instance" {

  #For_Each
  for_each = tomap({
    automate-instance-micro = "t2.micro"
    # automate-instace-medium = "t2.micro"
  })

  # interpolation
  key_name = aws_key_pair.my-key.key_name

  # ALWAYS use vpc_security_group_ids with SG ID
  vpc_security_group_ids = [aws_security_group.my-sg.id]

  instance_type = var.ec2_instance_type
  ami           = var.ec2_ami_id # ubuntu machine
  user_data = file("install_nginx.sh") # it will install nginx via shell script file when the instance is running
  # user_data is a optional argument that allows to some shell_script or some commands at startup

  root_block_device {
    volume_size = var.env == "prod" ? 8 : var.ec2_default_root_storage_size
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
  }

}


# new instance for import from aws
# resource "ec2_instace" "my-new-instace" {
#   ami = "unknown"
#   instance_type = "unknown"
# }