resource "azurerm_resource_group" "rg01" {
    name = "rg01"
    location = "eastus"
  
}
resource "azurerm_virtual_network" "vnet01" {
    name = "vnet01"
    resource_group_name = azurerm_resource_group.rg01.name
    location = azurerm_resource_group.rg01.location
    address_space = ["10.0.0.0/16"]
  
}

resource "azurerm_subnet" "subnetA" {
    name = "subnetA"
    address_prefixes = ["10.0.0.0/24"]
    resource_group_name = azurerm_resource_group.rg01.name
    virtual_network_name = azurerm_virtual_network.vnet01.name
  
}

resource "azurerm_network_interface" "nic" {
    count = 2
    name = "nic0${count.index + 1}"
    resource_group_name = azurerm_resource_group.rg01.name
    location = azurerm_resource_group.rg01.location

    ip_configuration {
      name = "ipconfig1"
      private_ip_address_allocation = "Dynamic" 
      subnet_id = azurerm_subnet.subnetA.id     
    }  
}

resource "azurerm_windows_virtual_machine" "name" {
    count = 2
    name = "vm0${count.index + 1}"
    resource_group_name = azurerm_resource_group.rg01.name
    location = azurerm_resource_group.rg01.location
    size = "standard_D2s_V3"
    network_interface_ids = [azurerm_network_interface.nic[count.index].id]
    admin_username = "azureadmin"
    admin_password = "password@123"
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }  

    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    }
}

