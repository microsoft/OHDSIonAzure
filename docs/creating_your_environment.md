# Creating your Environment Notes

This guide will let you work through the E2E for setting up your environment in your Azure subscription and Azure DevOps project.

1. Ensure you have completed the [infra setup](/docs/setup/setup_infra.md) including the [administrative steps](/infra/README.md/#administrative-steps) with your administrator for your Azure environment.
    * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_infra.md)

2. You can [setup your vocabulary](/docs/setup/setup_vocabulary.md) to populate your Azure SQL CDM in your environment.
    * You may also consider modifying the underlying [CDM schema](/sql/cdm/v5.3.1/omop_vocabulary_indexes_constraints/) if there's conflicts with your vocabulary.  See the [readme notes](/sql/README.md/#modifications-from-ohdsi) which calls out modifications to the CDM to confrom with the vocabulary
    * Conversely, you may also consider adjusting your vocabulary data to comply with your CDM schema.
    * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_vocabulary.md)

3. You can [setup Atlas and WebAPI](/docs/setup/setup_atlas_webapi.md) using the [broadsea webtools](/apps/broadsea-webtools/Dockerfile) image in your environment.
    * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_atlas_webapi.md)

4. You can [setup Achilles and Synthea](/docs/setup/setup_achilles_synthea.md) using the [broadsea methods](/apps/broadsea-methods/Dockerfile) image in your environment.
    * For troubleshooting please review the notes [here](/docs/troubleshooting/troubleshooting_achilles_synthea.md)