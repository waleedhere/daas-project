# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"

#   name = "nonporod-bastion"
#   ami                    = "ami-0d2a4a5d69e46ea0b"
#   instance_type          = "t2.micro"
#   key_name               = ""
#   monitoring             = true
#   vpc_security_group_ids = ["",""]
#   subnet_id              = ""

#   tags = {
    
#   }
# }

#########################################

resource "azurerm_resource_group" "jump-server-resources" {
  name     = "jump-server-rg"
  location = "West Europe"
}

resource "azurerm_linux_virtual_machine" "jumpserver" {
  name                = "jumpserver-machine"
  resource_group_name = azurerm_resource_group.jump-server-resources.name
  location            = azurerm_resource_group.jump-server-resources.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.jumpserver.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}