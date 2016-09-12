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
* Supports Docker cache for fast subsequent builds.
* All communication between APPUiO's OpenShift Container Platform and the dedicated build VMs is encrypted.
* To compensate the loss of custom builders it provides hooks to allow users to run a script before and/or after
  ``docker build``.

Build VMs
---------

RHEL and Docker versions in the build VMs are identical the ones on APPUiOs OpenShift Container Platform.

Build Hooks
-----------

Users can add ``.d2i/pre_build`` and/or ``.d2i/post_build`` scripts to the source repository where their
``Dockerfile`` resides. The scripts

* need to be executable and can be written in any language.
* have access to environment variables set in the buildconfig
* ``pre_build`` is executed just before ``docker build`` and has read/write to the Docker context, including the ``Dockerfile``
* ``post_build`` is executed just after ``docker build`` and has access to the Docker context and the built image
* are executed in the build VM as ``root``

Here you'll find an example which uses a ``pre_build`` script to install Maven and uses it to download an ``.war`` file from an artefact repository: https://github.com/appuio/appuio-docker-builder-example. The ``Dockerfile`` picks up the ``.war`` file downloaded by the ``pre_build`` script and adds to the image with an ``ADD`` instruction. In a real project the ``ARTIFACT`` environment variable would be configure in a ``BuildConfig``. The example uses JBoss EAP, which is only available to you if you ordered it. However this approach also works with other base images.

Known Issues
------------

* The OpenShift Container Platform Docker builder adds an ``ENV`` and a ``LABEL`` instructions containing information about
  the image source at end of the ``Dockerfile``. This is not yet implemented in the APPUiO secure Docker builder.
* `Binary <https://docs.openshift.com/enterprise/3.2/dev_guide/builds.html#binary-source>`__ and
  `image sources <https://docs.openshift.com/enterprise/3.2/dev_guide/builds.html#image-source>`__ are currently not
  implemented.
