provider "azurerm" {
  version = "~> 1.23"
  features {}
}

resource "azurerm_resource_group" "rgroup" {
  name     = var.rgroup
  location = var.location
}

resource "azurerm_virtual_network" "terraform_vnet" {
    name                = "${var.prefix}-vnet"
    location            = var.location
    resource_group_name = azurerm_resource_group.rgroup.name
    address_space       = [var.vnet_address_space]
}

resource "azurerm_subnet" "webserver_subnet" {
        count                = "${length(var.subnet_address_space)}"
        name                 =  "${element(var.subnet_name, count.index)}"
        resource_group_name  = azurerm_resource_group.rgroup.name
        virtual_network_name = azurerm_virtual_network.terraform_vnet.name
        address_prefix       = "${element(var.subnet_address_space, count.index)}"
}


resource "azurerm_network_interface" "networkinterface" {
    count               = 2
    name                = "${var.web_network_interface}-${format("%02d",count.index)}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rgroup.name

    ip_configuration {
        name                          = "testConfiguration"
        subnet_id                     = element(azurerm_subnet.webserver_subnet.*.id, count.index)
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          =  element(azurerm_public_ip.webserver_public_ip.*.id, count.index)
 }
}

resource "azurerm_public_ip" "webserver_public_ip" {
    count                = 2
    name                 = "public_ip-${format("%02d",count.index)}"
    location             = var.location
    resource_group_name  = azurerm_resource_group.rgroup.name
    allocation_method    = "Dynamic"
}

resource "azurerm_windows_virtual_machine" "windows_vm"{
    count                        = 2
    name                         = "VM-${format("%02d",count.index+1)}"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rgroup.name
    network_interface_ids        = [element(azurerm_network_interface.networkinterface.*.id, count.index)]
    size                         = "Standard_B1s"
    admin_username               = "jaganazure"
    admin_password               = "Security@321"

    os_disk {
        caching     = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher       = "MicrosoftWindowsServer"
        offer           = "WindowsServerSemiAnnual"
        sku             = "Datacenter-Core-1709-smalldisk"
        version         = "latest"
    }
}

