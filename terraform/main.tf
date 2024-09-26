# Define the variable
variable "subscription_id" {}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "flask_app_rg" {
  name     = "flask-app-resources"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "flask_app_vnet" {
  name                = "flask-app-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.flask_app_rg.location
  resource_group_name = azurerm_resource_group.flask_app_rg.name
}

# Create a subnet
resource "azurerm_subnet" "flask_app_subnet" {
  name                 = "flask-app-subnet"
  resource_group_name  = azurerm_resource_group.flask_app_rg.name
  virtual_network_name = azurerm_virtual_network.flask_app_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "flask_app_nsg" {
  name                = "flask-app-nsg"
  location            = azurerm_resource_group.flask_app_rg.location
  resource_group_name = azurerm_resource_group.flask_app_rg.name

  security_rule {
    name                       = "allow_ssh"
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
    name                       = "allow_flask"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5050"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a public IP address
resource "azurerm_public_ip" "flask_app_public_ip" {
  name                = "flask-app-public-ip"
  location            = azurerm_resource_group.flask_app_rg.location
  resource_group_name = azurerm_resource_group.flask_app_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a network interface
resource "azurerm_network_interface" "flask_app_nic" {
  name                = "flask-app-nic"
  location            = azurerm_resource_group.flask_app_rg.location
  resource_group_name = azurerm_resource_group.flask_app_rg.name

  ip_configuration {
    name                          = "flask-app-ip-config"
    subnet_id                     = azurerm_subnet.flask_app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.flask_app_public_ip.id
  }
}

# Associate the network interface with the network security group
resource "azurerm_network_interface_security_group_association" "flask_app_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.flask_app_nic.id
  network_security_group_id = azurerm_network_security_group.flask_app_nsg.id
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "flask_app_vm" {
  name                = "flask-app-vm"
  resource_group_name = azurerm_resource_group.flask_app_rg.name
  location            = azurerm_resource_group.flask_app_rg.location
  size                = "Standard_F2"
  admin_username      = "flaskadmin"
  network_interface_ids = [
    azurerm_network_interface.flask_app_nic.id,
  ]

  admin_ssh_key {
    username   = "flaskadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sleep 10
              sudo apt-get install -y python3-pip git
              sleep 15
              mkdir flask_app
              cd flask_app
              git clone https://github.com/jerinuser/battery-percent.git
              sleep 10
              cd battery-percent
              pip3 install -r requirements.txt
              sleep 10
              nohup python app.py > flask_output.log 2>&1 &
              EOF
  )
}

# Output the public IP address
output "flask_app_public_ip" {
  value = azurerm_public_ip.flask_app_public_ip.ip_address
}

output "ssh_command" {
  value = "ssh -v flaskadmin@${azurerm_public_ip.flask_app_public_ip.ip_address}"
}