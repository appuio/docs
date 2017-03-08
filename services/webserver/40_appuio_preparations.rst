Preparing the APPUiO project
============================

Before we go on with pushing to the APPUiO registry from Gitlab CI, we will prepare our APPUiO project such that it knows how to handle those incoming pushes. As this will be done using the CLI, we have to login to APPUiO and switch to the correct project (the OpenShift CLI is preinstalled in our Vagrant box):

::

    $ oc login
    $ oc project docs_example


Creating an ImageStream
"""""""""""""""""""""""

OpenShift introduces a concept called ImageStreams to handle docker images. This basically allows OpenShift to track changes to images and handle them appropriately. Each new push to the APPUiO registry updates the ImageStream which in turn triggers a new deployment of said image.

We will want to push images to an ImageStream called ``webserver`` with tags ``latest``, ``stable`` and ``live`` and handle those with deployments to ``staging``, ``preprod`` and ``prod``. We can create said ImageStream using the command ``oc create is webserver``.

**Relevant Readings / Resources**

#. `Managing Images [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/dev_guide/managing_images.html>`_