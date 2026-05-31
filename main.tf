
resource "aws_autoscaling_group" "test_asg" {
    max_size                  = 1
    min_size                  = 1
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnets.public.ids
    target_group_arns = [aws_lb_target_group.test1.arn]

    tag {
        key = "name"
        value = "terraform-example"
        propagate_at_launch = true
    }
    lifecycle{
        create_before_destroy = true
    }
}
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.public.ids

  tags = {
    Environment = "production"
  }
}
resource "aws_lb_target_group" "test1" {
  name     = "tf-example-lb-tg1"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test1.arn
  }
}
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test1.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_launch_configuration" "example" {
    image_id           = "ami-059fa25729652b51e"
    instance_type = "t3.micro"
    security_groups = [aws_security_group.example.id]
    user_data = <<-EOF
                #!bin/bash
                echo "Hello world" > index.html
                nohup busybox httpd -f -p ${var.web_port} &
                EOF
} 
resource "aws_security_group" "example" {
  name        = "example"
  description = "example"
  vpc_id      = aws_vpc.main.id
  tags = var.common_tags
}
resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.example.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.web_port
  ip_protocol = "tcp"
  to_port     = var.web_port
}
resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.example.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}
resource "aws_security_group" "lb_sg" {
  name        = "alb_sg"
  description = "example"
  vpc_id      = aws_vpc.main.id
  tags = var.common_tags
}
resource "aws_vpc_security_group_ingress_rule" "example1" {
  security_group_id = aws_security_group.lb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}
resource "aws_vpc_security_group_egress_rule" "example1" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}