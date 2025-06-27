
module "serverless_api"{
    source = "./modules/serverless-api"

    namespace = local.namespace
    region    = var.aws_region
    env       = var.environment
}