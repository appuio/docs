APPUiO Beta Specifics
=====================

APPUiO Beta is based on OpenShift Enterprise. This page describes APPUiO
Beta specific OpenShift configuration settings as well as features which
were added to APPUiO Beta that are not present in OpenShift.

Versions
--------

-  Operating System: Red Hat Enterprise Linux (RHEL) 7.2
-  OpenShift Enterprise: 3.2.0.46
-  Docker: 1.9.1

Please note that currently only OpenShift Clients which have the same version
as OpenShift Enterprise are guaranteed to work.
You can download matching clients directly from APPUiO: :doc:`getting-started`.

URLs and Domains
----------------

-  Master URL: https://master.appuio-beta.ch/
-  Metrics URL: https://metrics.appuio-beta.ch/
-  Logging URL: https://logging.appuio-beta.ch/
-  Application Domain: ``app.appuio-beta.ch``

Persistent Storage
------------------

APPUiO Beta currently uses NFSv4 based persistent storage. For now
volumes with the following sizes are available out of the box:

* 256 MiB
* 1 GiB

However you can contact us to get larger volumes: `Contact <http://appuio.ch/#contact>`__.
All volumes can be accessed with ReadWriteOnce (RWO) and ReadWriteMany (RWX)
access modes. Please see `Persistent Volumes <https://docs.openshift.com/enterprise/latest/dev_guide/persistent_volumes.html>`__
for more information.

Quotas and Limits
-----------------

We defined some Quotas and Limits for the Beta Platform. The current
values are referenced here: `What are the Quotas and Limits on the Beta Platform? <https://forum.appuio.ch/topic/18/what-are-the-quotas-and-limits-on-the-beta-platform>`__
