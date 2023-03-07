# Declare provider
provider "aws" {
  #region = "us-west-2"
  #access_key = "" #bad practice
  #secret_key = ""
  profile = "default"
}

# Declare variables
variable "ami" {
  default = "ami-00712dae9a53f8c15" # Ubuntu 20.04 LTS
}

variable "instance_type" {
  default = "t2.micro"
}

# Declare EC2 instances
resource "aws_instance" "ubuntu_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = "subnet-010456dae9322abe4"
  count         = 2
  tags = {
    Name = "ubuntu-instance"
  }
}

# Declare security group rule to allow SSH, HTTP, and custom ports
resource "aws_security_group" "allow_ssh_http_custom" {
  name_prefix = "allow_ssh_http_custom"

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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4949
    to_port     = 4949
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Attach security group to EC2 instances
resource "aws_network_interface_sg_attachment" "ubuntu_instance_sg_attachment" {
  count                       = 2  
  security_group_id           = aws_security_group.allow_ssh_http_custom.id
  network_interface_id        = aws_instance.ubuntu_instance[count.index].primary_network_interface_id
}

# Provision EC2 instance with Apache2 and Munin
#resource "null_resource" "install_apache2_munin" {
#  depends_on = [aws_instance.ubuntu_instance]
#}
#  connection {
#    type        = "ssh"
#    host        = aws_instance.ubuntu_instance[0].public_ip
#    user        = "ubuntu"
#    # private_key = file("~/.ssh/id_rsa")
#  }

 # provisioner "remote-exec" {
 #   inline = [
 #     "sudo apt-get update",
 #     "sudo apt-get install -y apache2 munin",
 #     "sudo systemctl enable munin-node",
 #     "sudo systemctl restart apache2",
 #     "sudo systemctl restart munin-node",
 #   ]
 # }