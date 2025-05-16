module "app" {
  source = "../../../app-module"
  environment = "production"
  pem_key_name = "demo-prod-01"
  stack_name = "demo-prod-01"
  vpc_id  = data.terraform_remote_state.global.outputs.vpc_id
  health_check_listener_arn = data.terraform_remote_state.shared.outputs.health_check_listener_arn
  elb_security_group_id = data.terraform_remote_state.shared.outputs.elb_security_group_id
}