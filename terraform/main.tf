resource "azurerm_resource_group" "devops_rg" {
  name     = "rg-devops-project"
  location = "West Europe"
}
resource "azurerm_virtual_network" "devops_vnet" {
  name                = "vnet-devops"
  address_space       = ["10.0.0.0/16"]
  location            = "France Central"
  resource_group_name = azurerm_resource_group.devops_rg.name
}

resource "azurerm_subnet" "devops_subnet" {
  name                 = "subnet-devops"
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devops_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "devops_nsg" {
  name                = "nsg-devops"
  location            = azurerm_virtual_network.devops_vnet.location
  resource_group_name = azurerm_resource_group.devops_rg.name
}
resource "azurerm_subnet_network_security_group_association" "devops_subnet_nsg" {
  subnet_id                 = azurerm_subnet.devops_subnet.id
  network_security_group_id = azurerm_network_security_group.devops_nsg.id
}
resource "azurerm_public_ip" "devops_public_ip" {
  name                = "pip-devops"
  location            = azurerm_virtual_network.devops_vnet.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "devops_nic" {
  name                = "nic-devops"
  location            = azurerm_virtual_network.devops_vnet.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_public_ip.id
  }
}
resource "azurerm_linux_virtual_machine" "devops_vm" {
  name                = "vm-devops"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_virtual_network.devops_vnet.location
  size                = "Standard_B1s"
  admin_username      = "mariem"

  network_interface_ids = [
    azurerm_network_interface.devops_nic.id
  ]

  admin_ssh_key {
    username   = "mariem"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_network_security_rule" "allow_ssh" {
  name                       = "allow-ssh"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.devops_rg.name
  network_security_group_name = azurerm_network_security_group.devops_nsg.name
}
resource "azurerm_network_security_rule" "allow_http" {
  name                       = "allow-http"
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.devops_rg.name
  network_security_group_name = azurerm_network_security_group.devops_nsg.name
}
resource "azurerm_container_registry" "devops_acr" {
  name                = "meriemdevopsacr2026"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_virtual_network.devops_vnet.location
  sku                 = "Basic"
  admin_enabled       = true
}
