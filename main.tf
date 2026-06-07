terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "CloudScale-RG-${var.student_name}"
  location = var.location
  tags = {
    Project     = "CloudScale"
    Environment = "Production"
    Student     = var.student_name
  }
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "CloudScale-VNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags
}

# 3. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "CloudScale-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Public IP (Static)
resource "azurerm_public_ip" "public_ip" {
  name                = "CloudScale-PIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard" 
  tags                = azurerm_resource_group.rg.tags
}

# 5. Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "CloudScale-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = azurerm_resource_group.rg.tags
}

# Network Interface attached to Subnet, PIP, and NSG
resource "azurerm_network_interface" "nic" {
  name                = "CloudScale-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  tags = azurerm_resource_group.rg.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 6. Linux Virtual Machine with Custom Script
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "CloudScale-VM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = "cloudscalevm"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = "CloudScale@2026!!"
custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker pull ${var.docker_image}
              sudo docker run -d -p 80:80 --restart always ${var.docker_image}
              EOF
  )
  tags = azurerm_resource_group.rg.tags
}