# APPUiO Beta Specifics

APPUiO Beta is based on OpenShift Enterprise.
This page describes APPUiO Beta specific OpenShift configuration settings as well as features which were added to APPUiO Beta that are not
present in OpenShift.

## Versions
  * Operating System: Red Hat Enterprise Linux (RHEL) 7.2
  * OpenShift Enterprise: 3.1.1.6
  * Docker: 1.8.2

Please note that currently only OpenShift Clients which version 3.1.1.6 are guaranteed to work.
You can download matching clients directly from APPUiO: http://docs.appuio.ch/en/latest/Getting%20Started/#cli

## URLs and Domains

  * Master URL: https://master.appuio-beta.ch/
  * Metrics URL: https://metrics.appuio-beta.ch/
  * Logging URL: https://logging.appuio-beta.ch/
  * Application Domain: app.appuio-beta.ch

## Persistent Storage

APPUiO Beta currently uses NFSv4 based persistent storage. For now only volumes with a size of 1 GiB are available out of the box.
However you can contact us to get larger volumes: http://appuio.ch/#contact.
All volumes can be accessed with ReadWriteOnce (RWO) and ReadWriteMany (RWX) access modes. Please see https://docs.openshift.com/enterprise/3.1/dev_guide/persistent_volumes.html
for more information.
