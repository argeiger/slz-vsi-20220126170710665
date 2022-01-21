variable "prefix" {
   description = "The prefix name in which you would like to have for your resources "
   type = string
   validation {
    error_message = "Prefix name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z][-a-z0-9]*)$", var.prefix))
  }
}

variable "region" {
   description = "Region to which to deploy resourses"
   type = string
}

#######################################################################
# Resource groups
#######################################################################
# <name of resource group> = { 
#     provision = bool   # Create the new resource group if it isn't there
#     prefix    = string # Add the prefix to the resource group name  
# }
variable "resource_groups" {
   description = "A map of objects representing a resource group and its attributes"
   type = map(object({
      provision = bool
      prefix = bool
   }))
   default = {
      cs-rg = {
         provision: true
         prefix: true
      },
      mgmt-vpc = {
         provision: true
         prefix: true
      }
      wrkld-vpc = {
         provision: true
         prefix: true
      }
   }
}

#######################################################################
# KMS variables
#######################################################################
variable "kms_provision" {
   description = "Determines if a KMS instance needs to be provisioned"
   type = bool
   default = false
}

variable "kms_service" {
   description = "The type of KMS instance needs to be provisioned.  Can be set to either keyprotect or hpcs"
   type = string
   default = "hpcs"
   
   validation {
     condition     = var.kms_service == "hpcs" || var.kms_service == "keyprotect"
     error_message = "KMS service can be set to only \"hpcs\" or \"keyprotect\"."
   }
}

variable "kms_resource_group" {
   description = "The resource group that the kms instance will be in"
   type = string
   default = "cs-rg"
}

variable "kms_name" {
   description = "The name of the KMS service.  If prefix is defined, the prefix will be appended to the beggining of the name"
   type = string
   default = "slz-kms"
}

variable "kms_location" {
   description = "Location of the KMS instance"
   type = string
   default = null
}

variable "kms_service_endpoint" {
   description = "The service endpoint of the kms instance"
   type = string
   default = "public-and-private"

   validation {
     condition     = var.kms_service_endpoint == "private-only" || var.kms_service_endpoint == "public-and-private"
     error_message = "KMS service endpoint can be set to only \"private-only\" or \"public-and-private\"."
   }
}

variable "kms_tags" {
   description = "Tags associated with the KMS instance"
   type = list(string)
   default = null
}


#######################################################################
# COS Instance variables
#######################################################################
variable "cos_service_name" {
  description = "Name of the Cloud Object Storage instance"
  type        = string
  default     = "slz-cos"
}

variable "cos_resource_group" {
  description = "The resource group that the cos instance will be in"
  type        = string
  default     = "cs-rg"
}

variable "cos_plan" {
  description = "COS plan type"
  type        = string
  default     = "standard"
}

variable "cos_region" {
  description = "Provisioning Region.  This should not change for global"
  type        = string
  default     = "global"
}

variable "cos_parameters" {
  description = "Arbitrary parameters to pass cos instance"
  type        = map(string)
  default     = null
}

variable "cos_key_parameters" {
  description = "Arbitrary parameters to pass to resource key"
  type        = map(string)
  default     = null
}

variable "cos_bind_resource_key" {
  description = "Enable this to bind key to cos instance (true/false)"
  type        = bool
  default     = true
}

variable "cos_resource_key_name" {
  description = "Name of the key"
  type        = string
  default     = "slz-cos-instance-key"
}

variable "cos_role" {
  description = "Name of the user role (Valid roles are Writer, Reader, Manager, Administrator, Operator, Viewer, Editor.)"
  type        = string
  default     = "Writer"
}

variable "cos_key_tags" {
  description = "Tags that should be applied to the key"
  type        = list(string)
  default     = null
}

variable "cos_tags" {
  description = "Tags that should be applied to the service"
  type        = list(string)
  default     = null
}

### Buckets

variable "mgmt_flow_log_bucket_name" {
   description = "The name of the bucket that management flow logs will be sent. If prefix is defined, it will be appended to this name"
   type = string
   default = "mgmt-flow-logs"
}

variable "mgmt_flow_log_bucket_storage_class" {
   description = "The storage class for the flow log bucket to use"
   type = string
   default = null
}

variable "mgmt_flow_log_bucket_endpoint_type" {
   description = ""
   type = string
   default = null
}

variable "mgmt_flow_log_encryption_key_name" {
   description = "Encryption key for the management flow log bucket"
   type = string
   default = "mgmt-flow-log-key"
}

variable "wrkld_flow_log_bucket_name" {
   description = "The name of the bucket that management flow logs will be sent.  If prefix is defined, it will be appended to this name"
   type = string
   default = "wrkld-flow-logs"
}

variable "wrkld_flow_log_bucket_storage_class" {
   description = "The storage class for the flow log bucket to use"
   type = string
   default = null
}

variable "wrkld_flow_log_bucket_endpoint_type" {
   description = "The name of the bucket that management flow logs will be sent."
   type = string
   default = null
}

variable "wrkld_flow_log_encryption_key_name" {
   description = "Encryption key for the management flow log bucket"
   type = string
   default = "wrkld-flow-log-key"
}

#######################################################################
# Common VPC variables
#######################################################################
variable "default_image_id" {
   description = "The default image id that will be used for the VSI"
   type = string
   default = ""
}

#######################################################################
# Management VPC variables
#######################################################################

variable "mgmt_resource_group_name" {
   description = "The name of the resource group that the management VPC resources will be in"
   type = string
   default = "mgmt-vpc"
}

variable "mgmt_block_storage_encryption_key_name" {
   description = "Name of the encryption key.  Default is <prefix>-mgmnt-encryption-key"
   type = string
   default = "mgmt-block-storage-key"
}

variable "mgmt_vpc_name" {
   description = "The name of the Management VPC"
   type = string
   default = "mgmt-vpc"
}

variable "mgmt_vpc_provision" {
  description = "Flag indicating that the Management VPC should be provisioned."
  type        = bool
  default     = true
}

variable "mgmt_vpc_address_prefixes" {
  description = "Management VPC Address prefixes that will be defined for the VPC for a certain location"
  type        = map
  default     = {}
}

variable "mgmt_vpc_subnets" {
   description = "Management VPC IP range in CIDR notation from the address prefix"
   type = map 
   default = {}
}

variable "mgmt_acls" {
   description = "Management VPC Access Control List that establish inbound/outbound rules on the subnet"
   type = map
   default = {}
}

variable "mgmt_security_groups" {
   description = "Management VPC network rules that establish filtering to each network interface of a virtual server instance"
   type = map
   default = {}
}

variable "mgmt_ssh_keys" {
   description = "Management VPC SSH keys"
   type = list 
   default = []
}

variable "default_management_vsi_count" {
   description = "The default count for number of VSI's that will be provisioned in the management account"
   type = number
   default = null
}

variable "mgmt_vsis" {
   description = "A list of VSI's and their attributes that you would like to provision"
   type = list
   default = []
}

variable "mgmt_endpoint_gateways" {
   description = "Management VPC endpoint gateways that will be provisioned within"
   type = map
   default = {} 
}

variable "mgmt_loadbalancers" {
  description = "Map defining the information needed to create one or more loadbalancer service within the Management VPC"
  type = map
  default = {}
}

variable "mgmt_vpn_gateway" {
   description = "Management VPC VPN gateways"
   type = map
   default = {}
}

# Flow logs for management vpc
variable "mgmt_flow_log_name" {
   description = "Name of the flow logs"
   type = string
   default = "mgmt-flow-logs"
}

variable "mgmt_flow_log_active" {
   description = "Indicates whether the collector is active."
   type = bool
   default = true
}

variable "mgmt_flow_log_tags" {
   description = "The tags associated with the flow log."
   type = list(string)
   default = []
}

#######################################################################
# Workload VPC variables
#######################################################################
variable "wrkld_resource_group_name" {
   description = "The name of the resource group that the workload VPC resources will be in"
   type = string
   default = "wrkld-vpc"
}

variable "wrkld_block_storage_encryption_key_name" {
   description = "Name of the encryption key.  Default is <prefix>-wkrld-block-storage-key"
   type = string
   default = "wkrld-block-storage-key"
}

variable "wrkld_vpc_name" {
   description = "The name of the workload VPC"
   type = string
   default = "wrkld-vpc"
}

variable "wrkld_vpc_provision" {
  description = "Flag indicating that the instance should be provisioned."
  type        = bool
  default     = true
}

variable "wrkld_vpc_address_prefixes" {
  description = "Workload VPC Address prefixes that will be defined for the VPC for a certain location"
  type        = map
  default     = {}
}

variable "wrkld_vpc_subnets" {
   description = "Workload VPC IP range in CIDR notation from the address prefix"
   type = map 
   default = {}
}

variable "wrkld_acls" {
   description = "Workload VPC Access Control List that establish inbound/outbound rules on the subnet"
   type = map
   default = {}
}

variable "wrkld_security_groups" {
   description = "Workload VPC network rules that establish filtering to each network interface of a virtual server instance"
   type = map
   default = {}
}

variable "wrkld_ssh_keys" {
   description = "Workload VPC SSH keys"
   type = list 
   default = []
}

variable "default_workload_vsi_count" {
   description = "The default count for number of VSI's that will be provisioned in the workload account"
   type = number
   default = null
}

variable "wrkld_vsis" {
   description = "A list of VSI's and their attributes that you would like to provision within the Workload VPC"
   type = list
   default = []
}

variable "wrkld_endpoint_gateways" {
   description = "Workload VPC endpoint gateways"
   type = map
   default = {}
}

variable "wrkld_vpn_gateway" {
   description = "Workload VPC VPN gateways"
   type = map
   default = {}
}

variable "wrkld_loadbalancers" {
  description = "Map defining the information needed to create one or more loadbalancer service within the Workload VPC"
  type = map
  default = {}
}

variable "wrkld_vpc_container_cluster_cos" {
   description = "COS service instance name for the vpc container cluster"
   type = string
   default = null
}

# Flow logs for workload vpc
variable "wrkld_flow_log_name" {
   description = "Name of the flow logs"
   type = string
   default = "wrkld-flow-logs"
}

variable "wrkld_flow_log_active" {
   description = "Indicates whether the collector is active."
   type = bool
   default = true
}

variable "wrkld_flow_log_tags" {
   description = "The tags associated with the flow log."
   type = list(string)
   default = []
}

#######################################################################
# Transit Gateway Variables
#######################################################################
variable "transit_gateway_name" {
  description = "The name that you would like to give the transit gateway"
  type    = string
  default = null
}

variable "transit_gateway_resource_group" {
  description = "The resource group that the transit gateway will be in"
  type    = string
  default = "cs-rg"
}

variable "transit_gateway_global_routing" {
  description = "Connect to the networks outside their associated region"
  type    = bool
  default = false
}

variable "transit_gateway_tags" {
  description = "List of tags for the transit gateway"
  type    = list
  default = []
}

variable "transit_gateway_vpc_connections" {
  description = "List of vpcs to connect"
  type    = list
  default = []
}

variable "transit_gateway_classic_connections_count" {
  description = "Number of classic connections"
  type    = number
  default = 0
}