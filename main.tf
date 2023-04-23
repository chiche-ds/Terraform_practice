provider "aws" {
    region = "us-east-2"
  
}
/*resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]
*/
resource "aws_launch_configuration" "example" {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]


  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true

lifecycle {
  create_before_destroy = true
}

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
#creating auto scaling group using launch configuration 
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
  
}
data "aws_vpc" "default" {
  default = true
  
}
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
}