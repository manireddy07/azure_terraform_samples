Software
========
azure-cli-2.14.0
terraform_0.12.24_windows_amd64
vscode 1.51.1

Creating a Service Principal
============================

A Service Principal is an application within Azure Active Directory whose authentication tokens can be used as the client_id, client_secret, and tenant_id fields needed by Terraform (subscription_id can be independently recovered from your Azure account details).

It's possible to complete this task in either the Azure CLI or in the Azure Portal - in both we'll create a Service Principal which has Contributor rights to the subscription. It's also possible to assign other rights depending on your configuration.

Creating a Service Principal using the Azure CLI
Note
: If you're using the China, German or Government Azure Clouds - you'll need to first configure the Azure CLI to work with that Cloud. You can do this by running:

$ az cloud set --name AzureChinaCloud|AzureGermanCloud|AzureUSGovernment
Firstly, login to the Azure CLI using:

$ az login
Once logged in - it's possible to list the Subscriptions associated with the account via:

$ az account list
The output (similar to below) will display one or more Subscriptions - with the id field being the subscription_id field referenced above.

[
  {
    "cloudName": "AzureCloud",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "name": "PAYG Subscription",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "user@example.com",
      "type": "user"
    }
  }
]
Should you have more than one Subscription, you can specify the Subscription to use via the following command:

$ az account set --subscription="SUBSCRIPTION_ID"
We can now create the Service Principal which will have permissions to manage resources in the specified Subscription using the following command:

$ az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
This command will output 5 values:

{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
These values map to the Terraform variables like so:

appId is the client_id defined above.
password is the client_secret defined above.
tenant is the tenant_id defined above.
Finally, it's possible to test these values work as expected by first logging in:

$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
Once logged in as the Service Principal - we should be able to list the VM sizes by specifying an Azure region, for example here we use the West US region:

$ az vm list-sizes --location westus
Note
: If you're using the China, German or Government Azure Clouds - you will need to switch westus out for another region. You can find which regions are available by running:

$ az account list-locations
Finally, since we're logged into the Azure CLI as a Service Principal we recommend logging out of the Azure CLI (but you can instead log in using your user account):

$ az logout
Information on how to configure the Provider block using the newly created Service Principal credentials can be found below.

Creating a Service Principal in the Azure Portal
There are three tasks necessary to create a Service Principal using the Azure Portal:

Create an Application in Azure Active Directory, which will create an associated Service Principal
Generating a Client Secret for the Azure Active Directory Application, which you'll to authenticate
Grant the Service Principal access to manage resources in your Azure subscriptions
1. Creating an Application in Azure Active Directory
Firstly navigate to the Azure Active Directory overview within the Azure Portal - then select the App Registration blade. Click the New registration button at the top to add a new Application within Azure Active Directory. On this page, set the following values then press Create:

Name - this is a friendly identifier and can be anything (e.g. "Terraform")
Supported Account Types - this should be set to "Accounts in this organizational directory only (single-tenant)"
Redirect URI - you should choose "Web" for the URI type. the actual value can be left blank
At this point the newly created Azure Active Directory application should be visible on-screen - if it's not, navigate to the the App Registration blade and select the Azure Active Directory application.

At the top of this page, you'll need to take note of the "Application (client) ID" and the "Directory (tenant) ID", which you can use for the values of client_id and tenant_id respectively.

2. Generating a Client Secret for the Azure Active Directory Application
Now that the Azure Active Directory Application exists we can create a Client Secret which can be used for authentication - to do this select Certificates & secrets. This screen displays the Certificates and Client Secrets (i.e. passwords) which are associated with this Azure Active Directory Application.

On this screen, we can generate a new Client Secret by clicking the New client secret button, then entering a Description and selecting an Expiry Date, and then pressing Add. Once the Client Secret has been generated it will be displayed on screen - this is only displayed once so be sure to copy it now (otherwise you will need to regenerate a new secret). This value is the client_secret you will need it.

3. Granting the Application access to manage resources in your Azure Subscription
Once the Application exists in Azure Active Directory - we can grant it permissions to modify resources in the Subscription. To do this, navigate to the Subscriptions blade within the Azure Portal, then select the Subscription you wish to use, then click Access Control (IAM), and finally Add > Add role assignment.

Firstly, specify a Role which grants the appropriate permissions needed for the Service Principal (for example, Contributor will grant Read/Write on all resources in the Subscription). There's more information about the built in roles available here.

Secondly, search for and select the name of the Service Principal created in Azure Active Directory to assign it this role - then press Save.

Configuring the Service Principal in Terraform
As we've obtained the credentials for this Service Principal - it's possible to configure them in a few different ways.

When storing the credentials as Environment Variables, for example:

$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
The following Provider block can be specified - where 2.5.0 is the version of the Azure Provider that you'd like to use:

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.5.0"
  features {}
}
More information on the fields supported in the Provider block can be found here.

At this point running either terraform plan or terraform apply should allow Terraform to run using the Service Principal to authenticate.

It's also possible to configure these variables either in-line or from using variables in Terraform (as the client_secret is in this example), like so:

NOTE:
We'd recommend not defining these variables in-line since they could easily be checked into Source Control.

variable "client_secret" {
}

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = var.client_secret
  tenant_id       = "00000000-0000-0000-0000-000000000000"

  features {}
}
More information on the fields supported in the Provider block can be found here.

At this point running either terraform plan or terraform apply should allow Terraform to run using the Service Principal to authenticate.