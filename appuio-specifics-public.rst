APPUiO Public Platform Specifics
===============================

APPUiO is based on OpenShift Container Platform. This page describes APPUiO
specific OpenShift configuration settings as well as features which
were added to APPUiO that are not present in OpenShift.

Versions
--------

- Operating System: Red Hat Enterprise Linux (RHEL) 7.2
- OpenShift Container Platform: 3.2.1.13
- Docker: 1.10.3

Please note that currently only OpenShift Clients which have the same version
as OpenShift Container Platform are guaranteed to work.
You can download matching clients directly from APPUiO: :doc:`getting-started`.

URLs and Domains
----------------

- Master URL: https://console.appuio.ch/
- Metrics URL: https://metrics.appuio.ch/
- Logging URL: https://logging.appuio.ch/
- Application Domain: ``appuioapp.ch``

Persistent Storage
------------------

APPUiO currently uses GlusterFS based persistent storage. For now
volumes with the following sizes are available out of the box:

* 1 GiB
* 5 GiB
* 20 GiB
* 50 GiB

However you can contact us to get larger volumes: `Contact <http://appuio.ch/#contact>`__.
All volumes can be accessed with ReadWriteOnce (RWO) and ReadWriteMany (RWX)
access modes. Please see `Persistent Volumes <https://docs.openshift.com/enterprise/latest/dev_guide/persistent_volumes.html>`__
for more information.

Quotas and Limits
-----------------

The quotas are defined in the project size you ordered. The exact numbers can be found
on the product site `APPUiO Public Platform <https://appuio.ch/public.html>`__

Secure Docker Builds
--------------------

Usually Docker builds from ``Dockerfile`` have to be disabled on multi-tenant platforms for
security reasons. However, APPUiO uses it's own implementation to securely run Docker builds
in dedicated VMs: :ref:`appuio_docker_builder`

Let's Encrypt Integration
-------------------------

Let's Encrypt is a certificate authority that provides free SSL/TLS certificates which are accepted by most of todays browser via an automated process. APPUiO provides integration with Let's Encrypt to automatically create, sign, install and renew certificates for your Domains running on APPUiO: :doc:`letsencrypt-integration`

Email Gateway
-------------

To send emails to external entities, you should SMTP relay via the email gateway at ``mxout.appuio.ch``.

To include the APPUiO email gateway in your existing SPF policy, you can include or redirect to ``spf.appuio.ch``.

Example DNS record:

.. code::

    @ IN TXT "v=spf1 ... include:spf.appuio.ch ~all"

Or if you send emails for your domain exclusivly from appuio:

.. code::

    @ IN TXT "v=spf1 redirect=spf.appuio.ch"

Features
--------

Most features are considered as stable. But there are some exceptions, mainly
the following two features are not yet as stable as we want and therefore declare
them as Beta:

* **Metrics**: The metrics storage fails from time to time and looses all it's data.
  This is being fixed together with Red Hat.
* **Logging**: This is not yet as stable as it should be, we're continuing to improve it.
* **Failover IP**: The high availability of service IPs (application router and master loadbalancer)
  is not yet completely automated. We're also continue to work on that.
