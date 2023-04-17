provider "aws" {
    region = "us-east-2"
  
}
resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true


  tags = {
    "Name" = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow web access"
    from_port = var.server_port
    protocol = "tcp"
    to_port = var.server_port
  } 
  
}
variable "server_port" {
  description = "the port the server will use for http "
  type        = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "this is the public ip address of the web server "
  
}