#######################################################################
# Values that need input
#######################################################################
# A prefix that you would like applied to all resources
prefix = "<USER INPUT REQUIRED>"

# The region that resources will be provisioned in
region = "<USER INPUT REQUIRED>"

# SSH keys for each VPC.  
# Note: They can not use the same key
mgmt_ssh_keys = [
    {
      name = "mgmt-sshkey"
      public_key = "<USER INPUT REQUIRED>"
      tags = []
    }
  ]

wrkld_ssh_keys = [
    {
      name = "wrkld-sshkey"
      public_key = "<USER INPUT REQUIRED>"
      tags = []
    }
  ]

# Sets a default OS image to use if you do not specify on a VSI basis
default_image_id = "<USER INPUT REQUIRED>"


#######################################################################
# Common service variables
#######################################################################

#######################################################################
# KMS service variables
#######################################################################

#######################################################################
# Management VPC variables
#######################################################################
mgmt_vpc_address_prefixes = {
    mgmt-zone1-cidr-1 = {
      zone_number = "1"
      cidr = "10.10.0.0/18"
    },
    mgmt-zone2-cidr-1 = {
      zone_number = "2"
      cidr = "10.20.0.0/18"
    },
    mgmt-zone3-cidr-1 = {
      zone_number = "3"
      cidr = "10.30.0.0/18"
    }
  }

mgmt_vpc_subnets = {
    mgmt-zone-1-subnet-vsi = {
      zone_number = "1"
      cidr_block = "10.10.10.0/24"
      network_acl = "mgmt-base-acl"
    },
    mgmt-zone-1-subnet-vpe = {
      zone_number = "1"
      cidr_block = "10.10.20.0/24"
      network_acl = "mgmt-base-acl"
    },
    mgmt-zone-1-subnet-vpn = {
      zone_number = "1"
      cidr_block = "10.10.30.0/24"
      network_acl = "mgmt-base-acl"
    },
    mgmt-zone-2-subnet-vsi = {
      zone_number = "2"
      cidr_block = "10.20.10.0/24"
      network_acl = "mgmt-base-acl"
    },
    mgmt-zone-2-subnet-vpe = {
      zone_number = "2"
      cidr_block = "10.20.20.0/24"
      network_acl = "mgmt-base-acl"
    },
    mgmt-zone-3-subnet-vsi = {
      zone_number = "3"
      cidr_block = "10.30.10.0/24"
      network_acl = "mgmt-base-acl"
    },
    mgmt-zone-3-subnet-vpe = {
      zone_number = "3"
      cidr_block = "10.30.20.0/24"
      network_acl = "mgmt-base-acl"
    }
  }

mgmt_acls = {
  mgmt-base-acl = {
      rules = [
        {
        name        = "inbound-allow-ibm"
        action      = "allow"
        source      = "161.26.0.0/16"
        destination = "10.0.0.0/8"
        direction   = "inbound"
        },
        {
        name        = "inbound-allow-10-network"
        action      = "allow"
        source      = "10.0.0.0/8"
        destination = "10.0.0.0/8"
        direction   = "inbound"
        },
        {
        name        = "outbound-all"
        action      = "allow"
        source      = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction   = "outbound"
        }
      ]
  }
}

mgmt_security_groups = {
  mgmt-base-security-group = {
      rules = [
        {
            direction = "inbound"
            remote = "mgmt-base-security-group"
        },
        {
            direction   = "inbound"
            remote      = "161.26.0.0/16"
        },
        {
            direction   = "inbound"
            remote      = "10.0.0.0/8"
        },
        {
            direction = "outbound"
            remote = "mgmt-base-security-group"
        },
        {
            direction = "outbound"
            remote = "161.26.0.0/16"
            tcp =[{
              port_min = 80
              port_max = 80
            }]
        },
        {
            direction = "outbound"
            remote = "161.26.0.0/16"
            tcp =[{
              port_min = 443
              port_max = 443
            }]
        },
        {
            direction = "outbound"
            remote = "161.26.0.0/16"
            udp =[{
              port_min = 53
              port_max = 53
            }]
        }
      ]
  }
}

mgmt_vsis = [
   {
      count = 1
      name = "mgmt-server-zone-1"
      image_id = ""
      profile = "cx2-2x4"
      subnet = "mgmt-zone-1-subnet-vsi"
      security_groups = ["mgmt-base-security-group"]
      ssh_key_list = ["mgmt-sshkey"]
   },
   {
      count = 1
      name = "mgmt-server-zone-2"
      image_id = ""
      profile = "cx2-2x4"
      subnet = "mgmt-zone-2-subnet-vsi"
      security_groups = ["mgmt-base-security-group"]
      ssh_key_list = ["mgmt-sshkey"]
   },
   {
      count = 1
      name = "mgmt-server-zone-3"
      image_id = ""
      profile = "cx2-2x4"
      subnet = "mgmt-zone-3-subnet-vsi"
      security_groups = ["mgmt-base-security-group"]
      ssh_key_list = ["mgmt-sshkey"]
   },
]

mgmt_endpoint_gateways = {
   "cos" = {
      endpoint_crn = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.{REGION}.cloud-object-storage.appdomain.cloud"
      subnets = ["mgmt-zone-1-subnet-vpe", "mgmt-zone-2-subnet-vpe", "mgmt-zone-3-subnet-vpe"]
    }
} 

mgmt_vpn_gateway = {
  mgmt-vpn = {
    subnet = "mgmt-zone-1-subnet-vpn"
    connection = {}
  }
}

#######################################################################
# Workload VPC variables
#######################################################################
wrkld_vpc_address_prefixes = {
    wrkld-zone1-cidr-1 = {
      zone_number = "1"
      cidr = "10.40.0.0/18"
    },
    wrkld-zone2-cidr-1 = {
      zone_number = "2"
      cidr = "10.50.0.0/18"
    },
    wrkld-zone3-cidr-1 = {
      zone_number = "3"
      cidr = "10.60.0.0/18"
    }
  }

wrkld_vpc_subnets = {
    wrkld-zone-1-subnet-vsi = {
      zone_number = "1"
      cidr_block = "10.40.10.0/24"
      network_acl = "wrkld-base-acl"
    },
    wrkld-zone-1-subnet-vpe = {
      zone_number = "1"
      cidr_block = "10.40.20.0/24"
      network_acl = "wrkld-base-acl"
    },
    wrkld-zone-1-subnet-vpn = {
      zone_number = "1"
      cidr_block = "10.40.30.0/24"
      network_acl = "wrkld-base-acl"
    },
    wrkld-zone-2-subnet-vsi = {
      zone_number = "2"
      cidr_block = "10.50.10.0/24"
      network_acl = "wrkld-base-acl"
    },
    wrkld-zone-2-subnet-vpe = {
      zone_number = "2"
      cidr_block = "10.50.20.0/24"
      network_acl = "wrkld-base-acl"
    },
    wrkld-zone-3-subnet-vsi = {
      zone_number = "3"
      cidr_block = "10.60.10.0/24"
      network_acl = "wrkld-base-acl"
    },
    wrkld-zone-3-subnet-vpe = {
      zone_number = "3"
      cidr_block = "10.60.20.0/24"
      network_acl = "wrkld-base-acl"
    }
  }

wrkld_acls = {
  wrkld-base-acl = {
      rules = [
        {
        name        = "inbound-allow-ibm"
        action      = "allow"
        source      = "161.26.0.0/16"
        destination = "10.0.0.0/8"
        direction   = "inbound"
        },
        {
        name        = "inbound-allow-10-network"
        action      = "allow"
        source      = "10.0.0.0/8"
        destination = "10.0.0.0/8"
        direction   = "inbound"
        },
        {
        name        = "outbound-all"
        action      = "allow"
        source      = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction   = "outbound"
        }
      ]
  }
}

wrkld_security_groups = {
  wrkld-base-security-group = {
      rules = [
        {
            direction = "inbound"
            remote = "wrkld-base-security-group"
        },
        {
            direction   = "inbound"
            remote      = "161.26.0.0/16"
        },
        {
            direction   = "inbound"
            remote      = "10.0.0.0/8"
        },
        {
            direction = "outbound"
            remote = "wrkld-base-security-group"
        },
        {
            direction = "outbound"
            remote = "161.26.0.0/16"
            tcp =[{
              port_min = 80
              port_max = 80
            }]
        },
        {
            direction = "outbound"
            remote = "161.26.0.0/16"
            tcp =[{
              port_min = 443
              port_max = 443
            }]
        },
        {
            direction = "outbound"
            remote = "161.26.0.0/16"
            udp =[{
              port_min = 53
              port_max = 53
            }]
        }
      ]
  }
}

wrkld_vsis = [
   {
      count = 1
      name = "wrkld-server-zone-1"
      image_id = ""
      profile = "cx2-2x4"
      subnet = "wrkld-zone-1-subnet-vsi"
      security_groups = ["wrkld-base-security-group"]
      ssh_key_list = ["wrkld-sshkey"]
   },
   {
      count = 1
      name = "wrkld-server-zone-2"
      image_id = ""
      profile = "cx2-2x4"
      subnet = "wrkld-zone-2-subnet-vsi"
      security_groups = ["wrkld-base-security-group"]
      ssh_key_list = ["wrkld-sshkey"]
   },
   {
      count = 1
      name = "wrkld-server-zone-3"
      image_id = ""
      profile = "cx2-2x4"
      subnet = "wrkld-zone-3-subnet-vsi"
      security_groups = ["wrkld-base-security-group"]
      ssh_key_list = ["wrkld-sshkey"]
   },
]

wrkld_endpoint_gateways = {
  "cos" = {
    endpoint_crn = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.{REGION}.cloud-object-storage.appdomain.cloud"
    subnets = ["wrkld-zone-1-subnet-vpe", "wrkld-zone-2-subnet-vpe", "wrkld-zone-3-subnet-vpe"]
  }
} 

wrkld_vpn_gateway = {
  wrkld-vpn = {
    subnet = "wrkld-zone-1-subnet-vpn"
    connection = {}
  }
}

