APPUiO Secure Docker Builder
============================

Rationale
---------

Docker builds from Dockerfiles need access to the Docker Socket and are therefore inherently insecure:
https://docs.docker.com/engine/security/security/#/docker-daemon-attack-surface.
For this reason most multi-tenant container platforms do not support Docker builds.
While OpenShift Container Platform, on which APPUiO is based, improves the security
of builds through the use of SELinux, they are still not secure enough to run
on a multi-tenant platform. Indeed we have we have disabled the
`custom build strategy (custom builders) <https://docs.openshift.com/enterprise/3.2/architecture/core_concepts/builds_and_image_streams.html#custom-build>`__
on APPUiO for this reason.

Features
--------

However, since we regard building Docker images from Dockerfiles
as a vital feature, APPUiO provides its own mechanism called the "APPUiO secure Docker builder" to offer this.
APPUiO secure Docker builder has the following features:

* It provides the same user experience as the OpenShift Container Platform Docker builder.
* Builds run in virtual machines dedicated to a single APPUiO project, which in turn run on dedicated hosts, i.e.
  outside of APPUiO's OpenShift Container Platform. Therefore providing full isolation between builds and customer containers
  as well as between builds from different customers.
* All communication between APPUiO's OpenShift Container Platform and the dedicated build VMs is encrypted.
* To compensate the loss of custom builders it provides hooks to allow users to run a script before and/or after
  ``docker build``.
 
Known Issues
------------

* The OpenShift Container Platform Docker builder adds an ``ENV`` and a ``LABEL`` instruction containing information about
  the image source at end of the ``Dockerfile``. This is not yet implemented in the APPUiO secure Docker builder.
* `Binary <https://docs.openshift.com/enterprise/3.2/dev_guide/builds.html#binary-source>`__ and
   `image sources <>`__ are currently not implemented.
