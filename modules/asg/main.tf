resource "aws_security_group" "asg_sg" {
  name        = "${var.name}-asg-sg"
  description = "Allow HTTP from ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tightened by ALB SG in front; you may restrict this
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", { nginx_port = var.nginx_port }))
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, { Name = "${var.name}-instance" })
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  health_check_type         = "ELB"
  health_check_grace_period = 60
  tag {
    key                 = "Name"
    value               = "${var.name}-asg"
    propagate_at_launch = true
  }
}

output "asg_name" { value = aws_autoscaling_group.asg.id }
