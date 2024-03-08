# private-endpoints
Private endpoints configuration within Azure using Terraform

If you disable public network access to your Azure Key Vaults, you can still allow Azure services to access them by using service endpoints or private endpoints.

Service Endpoints: Azure Service Endpoints provide secure and direct connectivity to Azure services over Microsoft's backbone network, bypassing the public internet. You can enable service endpoints for Azure Key Vault on the subnet where your Azure Web App is hosted. This will add the IP range of the subnet to the firewall of the Key Vault, allowing the Web App to access it.

Private Endpoints: Azure Private Endpoints provide a secure and private IP address to your Key Vault, effectively bringing it into your VNet. You can create a private endpoint for your Key Vault and enable 'Private Endpoint' on your Azure Web App's networking configuration. This will allow the Web App to access the Key Vault over a private network connection.

Within is an example of how you can create an Azure Web App and an Azure Key Vault, and connect them using a private endpoint. This example uses Terraform.

In this example, we first create a resource group, a virtual network, and a subnet. We then create an App Service Plan and an App Service (which represents the web app). We also create a Key Vault. Finally, we create a private endpoint in the subnet that connects to the Key Vault.

The enforce_private_link_endpoint_network_policies = true line in the subnet resource is important. This enables network policies on the subnet that are required for private endpoints to work.

Please replace "West Europe" with the Azure region you want to use, and replace "example-resources", "example-network", "internal", "example-appserviceplan", "example-appservice", "example-keyvault", "example-endpoint", and "example-connection" with the names you want to use for the resources.
