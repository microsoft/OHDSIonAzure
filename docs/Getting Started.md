# Getting Started

## Introduction

## Prerequisites

1. Azure Subscription
2. Resource Group
3. Logged in with a user that has Contributer role on the subscription and resource group

Once you click on deploy to azure buttom, you will be redirected to Custom deployment page, which will ask you to fill the following details.

| Name                          | Details                                                                                                       | Default Value                                                 |
|-------------------------------|---------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| Subscription                  | The name of the subscription.                                                                                 | N/A                                                           |
| Resource Group                | The name of the resource group.                                                                               | N/A                                                           |
| Region                        | The region of the resource group.                                                                             | As the resource group                                         |
| Location                      | The location of the resources.                                                                                | Resource group location                                       |
| Suffix                        | The suffix for the resource names.                                                                            | Unique string is being generated                              |
| CDM Container URL             | The URL of the CDM container. This could be replaced with any container containing any CDM tables.           | <https://omoppublic.blob.core.windows.net/shared/synthea1k/> |
| CDM SAS Token                 | The SAS token for accessing the CDM container. If no need for a SAS token, leave empty.                      | None                                                          |
| Postgres OMOP CDM Database Name| The name of the PostgreSQL OMOP CDM database.                                                                 | None                                                          |
| App Plan SKU                  | The SKU for the app plan.                                                                                     | S1                                                            |
| Postgres SKU                  | The SKU for the PostgreSQL database.                                                                          | Standard_D2s_v3                                               |
| Postgres Storage Size         | The storage size for the PostgreSQL database.                                                                 | 32                                                            |
| Postgres Admin Password       | The password for the PostgreSQL admin user.                                                                   | Unique password is being generated                            |
| Postgres WebAPI Admin Password| The password for the PostgreSQL WebAPI admin user.                                                            | Unique password is being generated                            |
| Postgres WebAPI App Password  | The password for the PostgreSQL WebAPI app user.                                                              | Unique password is being generated                            |
| Postgres OMOP CDM Password     | The password for the PostgreSQL OMOP CDM user.                                                                | Unique password is being generated                            |
| Atlas Security Admin Password | The password for the Atlas security admin user.                                                                | Unique password is being generated                            |
| Atlas Users List              | The list of users for the Atlas system should be provided in the following format: 'username1,password1,username2,password2,' and so on. Separate each set of credentials with a comma. For example, if you have two sets of credentials, it should look like this: 'user1,pass1,user2,pass2.' Ensure that the usernames and passwords are in the correct order and do not include any additional spaces or characters between the credentials. Note that this format allows you to specify multiple sets of username-password pairs for different users. Make sure each pair is properly formatted and separated by commas. | None                                                          |
| Local Debug                   | Enable local debugging mode.                                                                                   | false                                                         |

