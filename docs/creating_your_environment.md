# Creating your Environment Notes

This guide will let you work through the E2E for setting up your environment in your Azure subscription and Azure DevOps project.

> You can also check under the [video links doc](/docs/video_links.md) for other setup guides.

1. Ensure you have completed the [infra setup](/docs/setup/setup_infra.md) including the [administrative steps](/infra/README.md/#administrative-steps) with your administrator for your Azure environment.

* For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_infra.md)

* Setup your bootstrap resource group using the [bootstrap Terraform project](/infra/terraform/bootstrap/README.md)

[Setup Bootstrap Resource Group](https://user-images.githubusercontent.com/2498998/165582260-613fd12e-3226-46be-9e63-e9e8578676ba.mp4)

* Setup your OMOP resource group using the [OMOP Terraform project](/infra/terraform/omop/README.md)

[Setup OMOP Resource Group](https://user-images.githubusercontent.com/2498998/165582043-2f326c22-491e-4ce5-98af-ca10fcf8e80a.mp4)

2. You can [setup your vocabulary](/docs/setup/setup_vocabulary.md) to populate your Azure SQL CDM in your environment.

* You may also consider modifying the underlying [CDM schema](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/) if there's conflicts with your vocabulary.  See the [readme notes](/sql/README.md/#modifications-from-ohdsi) which calls out modifications to the CDM to confrom with the vocabulary
  * Conversely, you may also consider adjusting your vocabulary data to comply with your CDM schema.
  * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_vocabulary.md)

* Setup [your vocabulary](/docs/setup/setup_vocabulary.md)
  
[Setup Vocabulary](https://user-images.githubusercontent.com/2498998/165581645-175a1c9f-783d-4e4e-a064-d1b0148554a1.mp4)

3. Setup Broadsea webtools (Atlas / WebAPI) and broadsea methods (Achilles / ETL-Synthea) in your environment

* You can [setup Atlas and WebAPI](/docs/setup/setup_atlas_webapi.md) using the [broadsea webtools](/apps/broadsea-webtools/Dockerfile) image in your environment.
  * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_atlas_webapi.md)

* You can [setup Achilles and Synthea](/docs/setup/setup_achilles_synthea.md) using the [broadsea methods](/apps/broadsea-methods/Dockerfile) image in your environment.
  * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_achilles_synthea.md)

* Setup Broadsea in your environment

[Setup Broadsea](https://user-images.githubusercontent.com/2498998/165582632-a5cefdd5-8b84-424b-9f83-4453ab1760d4.mp4)
