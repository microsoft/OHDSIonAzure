# Broadsea-WebTools Notes

This is a combined image for [Atlas](https://github.com/OHDSI/Atlas) and [WebAPI](https://github.com/OHDSI/WebAPI).

You can review the [setup Atlas & WebApi notes](/docs/setup/setup_atlas_webapi.md) for more details.

## Atlas notes

Included in this directory are the [config folder](/apps/broadsea-webtools/config/) for [supervisord](https://github.com/OHDSI/Broadsea-WebTools/blob/master/Dockerfile#L14) and [scripts](/apps/broadsea-webtools/scripts/) folders, which are dependencies for setting up Atlas (including setting up [ssh](/apps/broadsea-webtools/scripts/enable_ssh.sh) and running the [deploy script](/apps/broadsea-webtools/scripts/deploy_script.sh)).

## WebApi Notes

Once [Web Api](https://github.com/OHDSI/WebAPI) is installed as part of the image, you will still need to [refresh Web Api](/sql/scripts/Web_Api_Refresh.sql), which is currently handled through the [pipeline](/pipelines/README.md/#broadsea-release-pipeline).