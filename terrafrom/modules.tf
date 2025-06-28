
module "backend_infra" {
    source = "./modules/backend-infra"

    namespace = local.namespace
    region    = var.aws_region
    env       = var.environment
}