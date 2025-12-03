locals {
  name = "demo-prod"
}

module "vpc" {
  source          = "../../modules/vpc"
  name            = local.name
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = { "0" = "10.0.1.0/24", "1" = "10.0.2.0/24" }
  private_subnets = { "0" = "10.0.11.0/24", "1" = "10.0.12.0/24" }
  tags            = { Environment = "dev" }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "${local.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "asg" {
  source               = "../../modules/asg"
  name                 = local.name
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  instance_type        = "t3.micro"
  desired_capacity     = 2
  min_size             = 2
  max_size             = 3
  instance_profile_name = aws_iam_instance_profile.instance_profile.name
  tags                 = { Environment = "prod" }
}

# ALB - use instance IDs from ASG (data source)
data "aws_instances" "asg_instances" {
  filters = [{
    name   = "tag:aws:autoscaling:groupName"
    values = [module.asg.asg_id]
  }]
}

module "alb" {
  source            = "../../modules/alb"
  name              = local.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_ids      = data.aws_instances.asg_instances.ids
  tags              = { Environment = "prod" }
}

output "alb_dns" {
  value = module.alb.alb_dns_name
}
