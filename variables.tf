##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "Environment" {
  type    = string
  default = "dev"
}

variable "Owner" {
  type    = string
  default = "masa"
}

variable "Project" {
  type    = string
  default = "project"
}

variable "Team" {
  type    = string
  default = "dev"
}

variable "ApplicationID" {
  type    = string
  default = "1"
}

variable "Limit" {
  type    = string
  default = "1"
}

variable "CostCenter" {
  type    = string
  default = "dev"
}

variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = "ws"
}

variable "Notification" {
  type = string
}

variable "filter" {
  type    = string
  default = "Workspace"
}

variable "tostop" {
  type    = string
  default = "true"
}


variable "time_period_start" {
  type    = string
  default = "2020-10-01_00:00"
}

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default     = "masa"
}

variable "region" {
  description = "The region where the resources are created."
  #default     = "ap-northeast-1"
  default = "us-east-1"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t2.nano"
}

# HashiCat application settings
variable "height" {
  default     = "400"
  description = "Image height in pixels."
}

variable "width" {
  default     = "600"
  description = "Image width in pixels."
}

variable "placeholder" {
  default = "placekitten.com"
  #default     = "placeskull.com"
  #default     = "placedog.net"
  description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
}
