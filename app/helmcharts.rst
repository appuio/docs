.. _tutorial_helm_charts:

Using Helm Charts to Deploy Services
====================================

Helm charts are a popular way to deploy pre-packaged applications or services
for development, efficiently.

.. admonition:: OpenShift Service Catalog vs. Helm Charts
    :class: note

    OpenShift Service Catalog is not supported nor available to be used on APPUiO.
    See our FAQ for details: :ref:`faq_service_catalog`

Helm charts can be deployed in a straight-forward manner with a single command.
You can compare this to installing packages on Linux machines.

Example: Postgres
-----------------

A sample install of Postgres could look as follows (assuming Helm 3 is installed on your machine):

.. code-block:: console

    # Login to APPUiO (copy the login command from the web console)
    oc login https://console.appuio.ch --token=<redacted>

    # Select the correct project
    oc project <projectname>

    # add the chart repository and update the local repo cache
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

    # Install Postgres with 1GB of persistent storage (on APPUiO 1GB and 5GB volumes are available by default)
    helm install test-db bitnami/postgresql --set global.storageClass=gluster-database --set persistence.size=1Gi

    # Show the newly installed database
    helm ls
    oc get pods

.. admonition:: Storage class
    :class: warning

    We strongly suggest using the ``gluster-database`` storage class when
    deploying databases on APPUiO to provision Gluster volumes which are
    configured with database-optimized settings.

Compatibility
-------------

Keep in mind that some Helm charts might not be compatible with OpenShift.
This is mostly due to the more strict security measures OpenShift enforces.
The easiest way to determine OpenShift compatibility is to install a certain
chart and see if everything works. If not, you'll have to investigate pods
that won't start more closely or find another chart.

See `Container Image Guidelines`_ in the OpenShift documentation for the
changes necessary to run an image on OpenShift.

.. _Container Image Guidelines:
    https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html#openshift-specific-guidelines

Related Resources
-----------------

- `Helm Quickstart Guide`_ (official docs)
- `Helm Hub`_ (canonical source for charts)
- `Helm Charts`_ (GitHub repository)
- `Deploy Applications with Helm 3`_ (OpenShift blog)

.. _Helm Quickstart Guide: https://helm.sh/docs/intro/quickstart/
.. _Helm Hub: https://hub.helm.sh/
.. _Helm Charts: https://github.com/helm/charts/tree/master/stable
.. _Deploy Applications with Helm 3: https://www.openshift.com/blog/openshift-4-3-deploy-applications-with-helm-3
