module "tfplan-functions" {
  source = "./common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
  source = "./common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
  source = "./common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "tfrun-functions" {
  source = "./common-functions/tfrun-functions/tfrun-functions.sentinel"
}

module "aws-functions" {
  source = "./aws-functions/aws-functions.sentinel"
}

module "tags-exceptions" {
  source = "./aws-functions/tags-exceptions.sentinel"
}

policy "check-mandatory-tags" {
  source = "./check-mandatory-tags.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "check-ec2-instance-type-in-devenv" {
  source = "./check-ec2-instance-type-in-devenv.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "check-cost-by-workspace-name" {
  source  = "./check-cost-by-workspace-name.sentinel"
  #	enforcement_level = "soft-mandatory"
  enforcement_level = "hard-mandatory"
}

