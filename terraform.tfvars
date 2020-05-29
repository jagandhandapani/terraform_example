rgroup                          = "Terraform_RG"
location                        = "westeurope"
prefix                          =  "terraform"
vnet_address_space              = "10.0.0.0/16"   
subnet_address_space            = ["10.0.1.0/24","10.0.2.0/24" ]
subnet_name                     = ["web_subnet","app_subnet" ]
web_network_interface           =   "webnic"
webserver_count                 = 2
