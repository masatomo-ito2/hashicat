provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

locals {
  common_tags = {
    Environment   = var.Environment,
    Project       = var.Project,
    Team          = var.Team,
    ApplicationID = var.ApplicationID,
    CostCenter    = var.CostCenter,
    Workspace     = var.TFC_WORKSPACE_NAME
  }
}

resource "aws_vpc" "hashicat" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = merge(local.common_tags,
    {
      Name = "${var.prefix}-vpc"
    }
  )
}


resource "aws_subnet" "hashicat" {
  vpc_id     = aws_vpc.hashicat.id
  cidr_block = var.subnet_prefix

  tags = merge(local.common_tags,
    {
      Name = "${var.prefix}-subnet"
    }
  )
}

resource "aws_security_group" "hashicat" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.hashicat.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["121.6.14.14/32", "0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["121.6.14.14/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["121.6.14.14/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = merge(local.common_tags,
    {
      Name = "${var.prefix}-security-group"
    }
  )
}

resource "random_id" "app-server-id" {
  prefix      = "${var.prefix}-hashicat-"
  byte_length = 8
}

resource "aws_internet_gateway" "hashicat" {
  vpc_id = aws_vpc.hashicat.id

  tags = merge(local.common_tags,
    {
      Name = "${var.prefix}-internet-gateway"
    }
  )
}

resource "aws_route_table" "hashicat" {
  vpc_id = aws_vpc.hashicat.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hashicat.id
  }
}

resource "aws_route_table_association" "hashicat" {
  subnet_id      = aws_subnet.hashicat.id
  route_table_id = aws_route_table.hashicat.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_eip" "hashicat" {
  instance = aws_instance.hashicat.id
  vpc      = true
}

resource "aws_eip_association" "hashicat" {
  instance_id   = aws_instance.hashicat.id
  allocation_id = aws_eip.hashicat.id
}

resource "aws_instance" "hashicat" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.hashicat.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.hashicat.id
  vpc_security_group_ids      = [aws_security_group.hashicat.id]

  tags = {
    Name          = "${var.prefix}-hashicat-instance",
    Environment   = var.Environment,
    Project       = var.Project,
    Team          = var.Team,
    ApplicationID = var.ApplicationID,
    CostCenter    = var.CostCenter,
    Workspace     = var.TFC_WORKSPACE_NAME
  }

}

resource "tls_private_key" "hashicat" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "${var.TFC_WORKSPACE_NAME}-${var.prefix}-ssh-key.pem"
}

resource "aws_key_pair" "hashicat" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.hashicat.public_key_openssh
}


module "workspace_budget" {
  source = "app.terraform.io/masa_org/workspace-budget/aws"

  workspace_name    = var.TFC_WORKSPACE_NAME
  limit             = var.Limit
  time_period_start = var.time_period_start
  subscriber_email  = var.Notification
}

module "stop_ec2_instance" {
  source  = "app.terraform.io/masa_org/lambda-scheduler-stop-start/aws"
  version = "2.10.0"

  name                           = "ec2_stop"
  cloudwatch_schedule_expression = "cron(0 0 ? * FRI *)"
  schedule_action                = "stop"
  ec2_schedule                   = "true"
  rds_schedule                   = "false"
  autoscaling_schedule           = "false"
  resources_tag = {
    key   = "Environment"
    value = "dev"
  }
  tags = local.common_tags
}

/*
provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Environment   = var.Environment,
    Project       = var.Project,
    Team          = var.Team,
    ApplicationID = var.ApplicationID,
    CostCenter    = var.CostCenter,
    Workspace     = var.TFC_WORKSPACE_NAME
  }
}

resource "aws_vpc" "hashicat" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true
}


resource "aws_subnet" "hashicat" {
  vpc_id     = aws_vpc.hashicat.id
  cidr_block = var.subnet_prefix
}

resource "aws_security_group" "hashicat" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.hashicat.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

resource "aws_internet_gateway" "hashicat" {
  vpc_id = aws_vpc.hashicat.id
}

resource "aws_route_table" "hashicat" {
  vpc_id = aws_vpc.hashicat.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hashicat.id
  }
}

resource "aws_route_table_association" "hashicat" {
  subnet_id      = aws_subnet.hashicat.id
  route_table_id = aws_route_table.hashicat.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_eip" "hashicat" {
  instance = aws_instance.hashicat.id
  vpc      = true
}

resource "aws_eip_association" "hashicat" {
  instance_id   = aws_instance.hashicat.id
  allocation_id = aws_eip.hashicat.id
}

resource "aws_instance" "hashicat" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.hashicat.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.hashicat.id
  vpc_security_group_ids      = [aws_security_group.hashicat.id]
  user_data                   = data.template_file.hashicat.rendered

  tags = {
    Name          = "${var.prefix}-hashicat-instance",
    Environment   = var.Environment,
    Project       = var.Project,
    Team          = var.Team,
    ApplicationID = var.ApplicationID,
    CostCenter    = var.CostCenter,
    Workspace     = var.TFC_WORKSPACE_NAME
    Owner         = var.Owner
  }
}

resource "tls_private_key" "hashicat" {
  algorithm = "RSA"
}

resource "aws_key_pair" "hashicat" {
  key_name   = "${var.prefix}-ssh-key2"
  public_key = tls_private_key.hashicat.public_key_openssh
}

data "template_file" "hashicat" {
  template = file("${path.module}/deploy.tpl")

  vars = {
    PLACEHOLDER = var.placeholder
    WIDTH       = var.width
    HEIGHT      = var.height
    PREFIX      = var.prefix
  }
}

module "workspace_budget" {
  source = "app.terraform.io/masa_org/workspace-budget/aws"

  workspace_name    = var.TFC_WORKSPACE_NAME
  limit             = var.Limit
  time_period_start = var.time_period_start
  subscriber_email  = var.Notification
}

module "stop_ec2_instance" {
  source  = "app.terraform.io/masa_org/lambda-scheduler-stop-start/aws"
  version = "2.10.0"

  name                           = "ec2_stop"
  cloudwatch_schedule_expression = "cron(0 0 ? * FRI *)"
  schedule_action                = "stop"
  ec2_schedule                   = "true"
  rds_schedule                   = "false"
  autoscaling_schedule           = "false"
  resources_tag = {
    key   = "Environment"
    value = "dev"
  }
  tags = local.common_tags
}
*/
