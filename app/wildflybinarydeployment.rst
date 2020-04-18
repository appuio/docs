Binary Deployment in Wildfly
============================

This example describes how to deploy a web archive (war) in Wildfly using the OpenShift client (oc) in binary mode.
The example is inspired by Red Hat's `blog <https://blog.openshift.com/binary-input-sources-openshift-3-2/>`__.

Create a new project
--------------------

.. code-block:: console

  oc new-project my-wildfly-project

Create the deployment folder structure
--------------------------------------
One or more war can be placed in the deployments folder. In this example an existing war file is downloaded from GitHub:

.. code-block:: console

  mkdir deployments
  wget -O deployments/ROOT.war 'https://github.com/appuio/hello-world-war/blob/master/repo/ch/appuio/hello-world-war/1.0.0/hello-world-war-1.0.0.war?raw=true'

If the provided `standalone.xml <https://github.com/openshift-s2i/s2i-wildfly/blob/master/10.1/contrib/wfcfg/standalone.xml>`__
does not fit the needs, a custom file can be placed in the cfg folder.

Create a new build using the Wildfly image
------------------------------------------

The flag *binary=true* indicates that this build will use the binary content instead of the url to the source code.

.. code-block:: console

  oc new-build --docker-image=openshift/wildfly-101-centos7 --binary=true --name=hello-world

Start the build
---------------

To trigger a build issue the command below. In a continuous deployment process this command can be repeated whenever there is a new binary or a new configuration available.

.. code-block:: console

  oc start-build hello-world --from-dir=.

Create a new app
----------------

.. code-block:: console

  oc new-app hello-world

Expose the service as route
---------------------------

.. code-block:: console

  oc expose svc hello-world
