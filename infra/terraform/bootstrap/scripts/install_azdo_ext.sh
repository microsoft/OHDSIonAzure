#!/bin/bash

if az devops extension list | grep "charleszipp.azure-pipelines-tasks-terraform"; then
   echo "Terraform extension exists."
else
   echo "Terraform extension does not exists. Attempting to install..."
   az devops extension install --publisher-id 'charleszipp' --extension-id 'azure-pipelines-tasks-terraform'
fi
