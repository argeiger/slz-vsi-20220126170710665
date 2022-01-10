locals {
  # If you add a new encryption key, you need to add it to this list
  kms_encryption_keys = [
      var.mgmt_block_storage_encryption_key_name, 
      var.mgmt_flow_log_encryption_key_name,
      var.wrkld_block_storage_encryption_key_name, 
      var.wrkld_flow_log_encryption_key_name
  ]

  s2s_authorizations = {
    block-storage = {
      source_service_name           = "server-protect"
      roles                         = ["Reader"]
      target_service_name           = (var.kms_service == "keyprotect" ? "kms" : "hs-crypto")
      target_resource_instance_id   = module.kms_instance.guid
    },
    cos-to-kms = {
      source_service_name           = "cloud-object-storage"
      roles                         = ["Reader"]
      target_service_name           = (var.kms_service == "keyprotect" ? "kms" : "hs-crypto")
      target_resource_instance_id   = module.kms_instance.guid
    },
    flow-logs-cos = {
      source_service_name           = "is"
      source_resource_type          = "flow-log-collector"
      roles                         = ["Writer"]
      target_service_name           = "cloud-object-storage"
      target_resource_group_id      = module.resource_groups[var.cos_resource_group].resource_group_id
    }
  }
}


#############################################
# Resource groups
#############################################

module "resource_groups" {
  for_each = var.resource_groups
  source = "terraform-ibm-modules/resource-management/ibm//modules/resource-group"
  version = "1.0.0"

  provision = each.value.provision
  name      = lookup(each.value, "prefix", false) == false ? each.key : "${var.prefix}-${each.key}"
}

#############################################
# KMS instance/keys
#############################################
module "kms_instance" {
  source = "git::https://git@github.com/slzone/terraform-kms-module.git//modules/instance"
  #source  = "../../terraform-kms-module/modules/instance"

  kms_provision = var.kms_provision
  resource_group_id = module.resource_groups[var.kms_resource_group].resource_group_id
  kms_service   = var.kms_service
  kms_name      = var.kms_name
  kms_plan      = (var.kms_service == "hpcs" ? "standard" : "tiered-pricing")   
  kms_location  = (var.kms_location != null) ? var.kms_location : var.region 
  kms_service_endpoint = var.kms_service_endpoint
}

module "kms_encryption_keys" {
  source = "git::https://git@github.com/slzone/terraform-kms-module.git//modules/key"
  #source  = "../../terraform-kms-module/modules/key"

  for_each = {for k in local.kms_encryption_keys: k => k}

  instance_id = module.kms_instance.guid
  key_name    = each.key
}

#############################################
# COS Instances
#############################################
module "cos_instance" {
  source = "terraform-ibm-modules/cos/ibm//modules/instance"
  version = "1.4.1"

  bind_resource_key = var.cos_bind_resource_key
  service_name      = (var.prefix != null ? "${var.prefix}-${var.cos_service_name}" : var.cos_service_name)
  resource_group_id = module.resource_groups[var.cos_resource_group].resource_group_id
  plan              = var.cos_plan
  region            = var.cos_region
  parameters        = var.cos_parameters
  tags              = var.cos_tags
  resource_key_name = var.cos_resource_key_name
  role              = var.cos_role
  key_tags          = var.cos_key_tags
  key_parameters    = var.cos_key_parameters
}

#############################################
# Authorizations
#############################################
module "authorization_policies" {
  source  = "terraform-ibm-modules/iam/ibm//modules/service-authorization"
  version = "1.2.2"

  for_each = local.s2s_authorizations

  source_service_name           = each.value.source_service_name
  roles                         = each.value.roles
  target_service_name           = each.value.target_service_name
  source_resource_instance_id   = lookup(each.value, "source_resource_instance_id", null)
  target_resource_instance_id   = lookup(each.value, "target_resource_instance_id", null)
  source_resource_type          = lookup(each.value, "source_resource_type", null)
  target_resource_type          = lookup(each.value, "target_resource_type", null)
  source_resource_group_id      = lookup(each.value, "source_resource_group_id", null)
  target_resource_group_id      = lookup(each.value, "target_resource_group_id", null)

  depends_on = [module.kms_instance, module.cos_instance]
}


#############################################
# Management VPC
#############################################
module "mgmt_vpc" {
  source = "git::https://git@github.com/slzone/terraform-vpc-module.git"
  #source = "../../terraform-vpc-module"
  
  region = var.region
  prefix = var.prefix
  resource_group_id = module.resource_groups[var.mgmt_resource_group_name].resource_group_id

  vpc_name = var.mgmt_vpc_name
  default_network_acl_name = (var.prefix != null ? "${var.prefix}-${var.mgmt_vpc_name}-default-acl" : null)
  default_security_group_name = (var.prefix != null ? "${var.prefix}-${var.mgmt_vpc_name}-default-sg" : null)
  default_routing_table_name = (var.prefix != null ? "${var.prefix}-${var.mgmt_vpc_name}-default-rt" : null)

  address_prefixes = var.mgmt_vpc_address_prefixes
  subnets = var.mgmt_vpc_subnets
  acls = var.mgmt_acls
  security_groups = var.mgmt_security_groups

  encryption_key_crn = module.kms_encryption_keys[var.mgmt_block_storage_encryption_key_name].key.crn
  ssh_keys = var.mgmt_ssh_keys
  servers = var.mgmt_vsis
  
  endpoint_gateways = { for k,v in var.mgmt_endpoint_gateways : 
    k => merge(v, {endpoint_crn=replace(v["endpoint_crn"], "{REGION}", var.region)}) 
  }

  loadbalancers = var.mgmt_loadbalancers
  vpn_gateway = var.mgmt_vpn_gateway

  depends_on = [module.authorization_policies]
}

# Flow log COS bucket
module "mgmt_flow_log_cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/bucket"
  version = "1.4.1"

  bucket_name           = (var.prefix != null ? "${var.prefix}-${var.mgmt_flow_log_bucket_name}" : var.mgmt_flow_log_bucket_name)
  cos_instance_id       = module.cos_instance.cos_instance_id
  location              = var.region
  storage_class       = (var.mgmt_flow_log_bucket_storage_class != null ? var.mgmt_flow_log_bucket_storage_class : "standard")
  endpoint_type       = (var.mgmt_flow_log_bucket_endpoint_type != null ?  var.mgmt_flow_log_bucket_endpoint_type  : "public")
  force_delete        = true
  kms_key_crn         = module.kms_encryption_keys[var.mgmt_flow_log_encryption_key_name].key.crn

  depends_on = [module.authorization_policies]
}

resource ibm_is_flow_log mgmt_flowlog {
  
  name = (var.prefix != null ? "${var.prefix}-${var.mgmt_flow_log_name}" : var.mgmt_flow_log_name)
  target = module.mgmt_vpc.vpc.id
  active = var.mgmt_flow_log_active
  storage_bucket = (var.prefix != null ? "${var.prefix}-${var.mgmt_flow_log_bucket_name}" : var.mgmt_flow_log_bucket_name)

  depends_on = [module.mgmt_flow_log_cos_bucket, module.mgmt_vpc]
}


#############################################
# Workload VPC
#############################################
module "wrkld_vpc" {
source = "git::https://git@github.com/slzone/terraform-vpc-module.git"
#source = "../../terraform-vpc-module"
  
  region = var.region
  prefix = var.prefix
  resource_group_id = module.resource_groups[var.wrkld_resource_group_name].resource_group_id

  vpc_name = var.wrkld_vpc_name
  default_network_acl_name = (var.prefix != null ? "${var.prefix}-${var.wrkld_vpc_name}-default-acl" : null)
  default_security_group_name = (var.prefix != null ? "${var.prefix}-${var.wrkld_vpc_name}-default-sg" : null)
  default_routing_table_name = (var.prefix != null ? "${var.prefix}-${var.wrkld_vpc_name}-default-rt" : null)

  address_prefixes = var.wrkld_vpc_address_prefixes
  subnets = var.wrkld_vpc_subnets
  acls = var.wrkld_acls
  security_groups = var.wrkld_security_groups

  encryption_key_crn = module.kms_encryption_keys[var.wrkld_block_storage_encryption_key_name].key.crn
  ssh_keys = var.wrkld_ssh_keys
  servers = var.wrkld_vsis
  endpoint_gateways = { for k,v in var.wrkld_endpoint_gateways : 
    k => merge(v, {endpoint_crn=replace(v["endpoint_crn"], "{REGION}", var.region)}) 
  }

  loadbalancers = var.wrkld_loadbalancers
  vpn_gateway = var.wrkld_vpn_gateway

  depends_on = [module.authorization_policies]
}

# Flow log COS bucket
module "wrkld_flow_log_cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/bucket"
  version = "1.4.1"

  bucket_name           = (var.prefix != null ? "${var.prefix}-${var.wrkld_flow_log_bucket_name}" : var.wrkld_flow_log_bucket_name)
  cos_instance_id       = module.cos_instance.cos_instance_id
  location              = var.region
  storage_class       = (var.wrkld_flow_log_bucket_storage_class != null ? var.wrkld_flow_log_bucket_storage_class : "standard")
  endpoint_type       = (var.wrkld_flow_log_bucket_endpoint_type != null ?  var.wrkld_flow_log_bucket_endpoint_type  : "public")
  force_delete        = true
  kms_key_crn         = module.kms_encryption_keys[var.wrkld_flow_log_encryption_key_name].key.crn

  depends_on = [module.authorization_policies]
}

resource ibm_is_flow_log wrkld_flowlog {
  
  name = (var.prefix != null ? "${var.prefix}-${var.wrkld_flow_log_name}" : var.wrkld_flow_log_name)
  target = module.wrkld_vpc.vpc.id
  active = var.wrkld_flow_log_active
  storage_bucket = (var.prefix != null ? "${var.prefix}-${var.wrkld_flow_log_bucket_name}" : var.wrkld_flow_log_bucket_name)

  depends_on = [module.wrkld_flow_log_cos_bucket, module.wrkld_vpc]
}

############################################
# Transit Gateway
############################################
module "tg-gateway-connection" {
  source = "terraform-ibm-modules/transit-gateway/ibm//modules/tg-gateway-connection"
  version = "1.0.0"

  transit_gateway_name = (var.transit_gateway_name != null ? var.transit_gateway_name : "${var.prefix}-tgw")
  location             = var.region
  global_routing       = var.transit_gateway_global_routing
  tags                 = var.transit_gateway_tags != null ? var.transit_gateway_tags : []
  resource_group_id    = module.resource_groups[var.transit_gateway_resource_group].resource_group_id
  vpc_connections      = [module.mgmt_vpc.vpc.crn, module.wrkld_vpc.vpc.crn]
  classic_connnections_count = var.transit_gateway_classic_connections_count

  depends_on = [module.mgmt_vpc, module.wrkld_vpc]
}