# resource "azurerm_resource_group" "rg" {
#   name     = "rg-${var.name}"
#   location = var.location
#   tags = {
#     owner  = "TM"
#     module = "capstone"
#   }
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "vnet-${var.name}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   address_space       = ["10.0.0.0/24"]
# }

# resource "azurerm_subnet" "public" {
#   name                            = "snet-app-${var.name}"
#   resource_group_name             = azurerm_resource_group.rg.name
#   virtual_network_name            = azurerm_virtual_network.vnet.name
#   address_prefixes                = ["10.0.0.64/26"]
#   default_outbound_access_enabled = true
# u}

# resource "azurerm_network_security_group" "main" {
#   name                = "nsg-app-${var.name}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   security_rule {
#     name                       = "Allow-HTTP"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "Allow-HTTPS"
#     priority                   = 101
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "443"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "Allow-SSH"
#     priority                   = 1000
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "public" {
#   subnet_id                 = azurerm_subnet.public.id
#   network_security_group_id = azurerm_network_security_group.main.id
# }

# resource "azurerm_subnet" "private" {
#   name                            = "snet-db-${var.name}"
#   resource_group_name             = azurerm_resource_group.rg.name
#   virtual_network_name            = azurerm_virtual_network.vnet.name
#   address_prefixes                = ["10.0.0.0/26"]
#   default_outbound_access_enabled = false
# }

# resource "azurerm_network_security_group" "private" {
#   name                = "nsg-db-${var.name}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
# }

# resource "azurerm_subnet_network_security_group_association" "private" {
#   subnet_id                 = azurerm_subnet.private.id
#   network_security_group_id = azurerm_network_security_group.private.id
# }

# resource "azurerm_public_ip" "main" {
#   name                = "pip-vm-${var.name}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "main" {
#   name                = "nic-${var.name}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "ipconfig-${var.name}"
#     subnet_id                     = azurerm_subnet.public.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.main.id
#   }
# }

# resource "azurerm_linux_virtual_machine" "main" {
#   name                            = "vm-${var.name}"
#   location                        = azurerm_resource_group.rg.location
#   resource_group_name             = azurerm_resource_group.rg.name
#   network_interface_ids           = [azurerm_network_interface.main.id]
#   size                            = "Standard_D2as_v5"
#   admin_username                  = "azureuser"
#   disable_password_authentication = true 
#   custom_data                     = filebase64("${path.module}/../scripts/init.sh")

#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = var.ssh_public_key
#   }

#   os_disk {
#     name                 = "osdisk-${var.name}"
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts-gen2"    
#     version   = "latest"
#   }
# }

# resource "azurerm_mssql_server" "main" {
#   name                          = "sql-${var.name}"
#   resource_group_name           = azurerm_resource_group.rg.name
#   location                      = azurerm_resource_group.rg.location
#   version                       = "12.0"
#   administrator_login           = "dbadmin"
#   administrator_login_password  = var.sql_admin_password
#   public_network_access_enabled = false
# }

# resource "azurerm_mssql_database" "main" {
#   name      = "db-${var.name}"
#   server_id = azurerm_mssql_server.main.id
#   sku_name  = "S0"
# }

# resource "azurerm_private_dns_zone" "sql" {
#   name                = "privatelink.database.windows.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
#   name                  = "vnet-link-sql"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.sql.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }

# resource "azurerm_private_endpoint" "sql" {
#   name                = "pe-sql-${var.name}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.private.id

#   private_service_connection {
#     name                           = "psc-sql-${var.name}"
#     private_connection_resource_id = azurerm_mssql_server.main.id
#     subresource_names              = ["sqlServer"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
#   }
# }