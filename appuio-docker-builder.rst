.. _appuio_docker_builder:

APPUiO Secure Docker Builder
============================

Rationale
---------

Docker builds from Dockerfiles need access to the Docker Socket and are
`inherently insecure <https://docs.docker.com/engine/security/security/#/docker-daemon-attack-surface>`__.
For this reason most multi-tenant container platforms do not support Docker builds.
While OpenShift Container Platform, on which APPUiO is based, improves the security
of builds through the use of SELinux, they are still not secure enough to run
on a multi-tenant platform. Indeed we have
`disabled <https://docs.openshift.org/latest/admin_guide/securing_builds.html>`__
the
`custom build strategy (custom builders) <https://docs.openshift.com/container-platform/3.4/architecture/core_concepts/builds_and_image_streams.html#custom-build>`__
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

User-customizable builder configuration
---------------------------------------

The source secret attached to the build strategy of a build configuration can
be used to configure the build. As per usual in OpenShift secrets values must
be encoded using `Base64 <https://en.wikipedia.org/wiki/Base64>`__.

Example
~~~~~~~

::

  $ oc export secrets example-source-auth
  apiVersion: v1
  kind: Secret
  metadata:
    name: example-source-auth
  type: Opaque
  data:
    ssh-privatekey: LS0…Cg==
    ssh-known-hosts: Iwo=
    ssh-config: Iwo=

The string ``Iwo=`` is ``#\n`` in Base64.


``ssh-privatekey``
~~~~~~~~~~~~~~~~~~

Private SSH key; see `OpenShift documentation
<https://docs.openshift.com/container-platform/3.4/dev_guide/builds.html#ssh-key-authentication>`__.


``ssh-known-hosts``
~~~~~~~~~~~~~~~~~~

If this attribute is set to anything, including the empty string, strict host
key checking is enabled (see ``StrictHostKeyChecking`` in
:manpage:`ssh_config(5)`). The host keys for the following hosting services are
already included by default:

* `GitHub <https://github.com/>`__
* `GitLab <https://about.gitlab.com/>`__
* `Atlassian Bitbucket <https://bitbucket.org/>`__

Other host keys can be added in Base64 format. Example retrieval command::

  $ ssh-keyscan git.example.net | base64
  Z2l[…]wo=


``ssh-config``
~~~~~~~~~~~~~~

SSH configuration snippet; added after the built-in options. Useful to specify
different configuration options for the SSH client (i.e. the `Ciphers` option;
see :manpage:`ssh_config(5)`).


Build VMs
---------

RHEL and Docker versions in the build VMs are identical the ones on APPUiOs OpenShift Container Platform.

Build Hooks
-----------

Users can add ``.d2i/pre_build`` and/or ``.d2i/post_build`` scripts to the source repository where their
``Dockerfile`` resides. The scripts

* need to be executable and can be written in any language.
* have access to environment variables set in the ``BuildConfig`` object, the
  variables documented for `custom OpenShift builder images
  <https://docs.openshift.com/container-platform/3.4/creating_images/custom.html#custom-builder-image>`__,
  ``DOCKERFILE_PATH`` (relative or absolute path to Dockerfile) and
  ``DOCKER_TAG`` (output Docker tag)
* ``pre_build`` is executed just before ``docker build`` and has read/write to
  the Docker context, including the ``Dockerfile`` (use ``$DOCKERFILE_PATH``;
  also passed as first argument); the output tag is given as the second argument
* ``post_build`` is executed just after ``docker build`` and has access to the
  Docker context and the built image
* are executed in the build VM as ``root``

Build Hook Example
~~~~~~~~~~~~~~~~~~

Here you'll find an example which uses a ``pre_build`` script to install Maven and uses it to download a ``.war`` file from an artefact repository: https://github.com/appuio/appuio-docker-builder-example. The ``Dockerfile`` picks up the ``.war`` file downloaded by the ``pre_build`` script and adds to the image with an ``ADD`` instruction. In a real project the ``ARTIFACT`` environment variable would be configure in a ``BuildConfig``. The example uses JBoss EAP, which is only available to you if you ordered it. However this approach also works with other base images.

Multi-stage builds
------------------

**Note**: As of September 2017 multi-stage builds are a beta feature included
in the secure Docker builder.

**Note**: Multi-stage builds can't be used when the source image for a build is
overridden using `.spec.strategy.dockerStrategy.from.name
<https://docs.openshift.com/container-platform/3.6/dev_guide/builds/build_strategies.html#docker-strategy-from>`__.

Docker 17.05 and newer support `multi-stage builds
<https://docs.docker.com/engine/userguide/eng-image/multistage-build/>`__ where
build stages can be partially reused for further stages. An example
``Dockerfile`` from the Docker documentation:

::

  FROM golang:1.7.3 as builder
  WORKDIR /go/src/github.com/alexellis/href-counter/
  RUN go get -d -v golang.org/x/net/html
  COPY app.go    .
  RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

  FROM alpine:latest
  RUN apk --no-cache add ca-certificates
  WORKDIR /root/
  COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
  CMD ["./app"]

Known Issues
------------

* The OpenShift Container Platform Docker builder exposes environment variables
  via an ``ENV`` instruction at the end of ``Dockerfile``. This is not yet
  implemented in the APPUiO secure Docker builder.
* `Binary <https://docs.openshift.com/container-platform/3.4/dev_guide/builds.html#binary-source>`__ and
  `image sources <https://docs.openshift.com/container-platform/3.4/dev_guide/builds.html#image-source>`__ are currently not
  implemented.
