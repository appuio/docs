Custom Builder
==============

Configuration
-------------

OpenShift supports `customizing the build process for images
<https://docs.openshift.org/latest/creating_images/custom.html>`__. APPUiO uses
this mechanism to :doc:`install its own builder for Docker images
<../appuio-docker-builder>`.

The image selection uses the `imageConfig` key in `master-config.yaml`
(`documentation
<https://docs.openshift.org/latest/install_config/master_node_configuration.html#master-config-image-config>`__).
Default value:

::

  imageConfig:
    format: openshift/origin-${component}:${version}
    latest: false

Example from a production cluster::

  imageConfig:
    format: 172.30.1.1:5000/cluster-infra/builder-${component}:${version}
    latest: false

Individual build strategies can be [enabled or disabled globally, per user,
group or project](https://docs.openshift.org/latest/admin_guide/securing_builds.html).
