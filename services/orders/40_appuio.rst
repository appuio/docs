Deploying to APPUiO
===================

Now that we have setup Jenkins and created a pipeline with which it can build and deploy to our environments, the only thing left to do is actually create the DeploymentConfigs and Services on APPUiO. As we have done this several times by now, we will only shortly summarize the commands.

The Jenkins pipeline for the *staging* environment will trigger a new Source-To-Image build which then creates an image called ``orders:latest``. The remaining stages will each pick up an existing image and retag it from *latest* to *stable* and from *stable* to *live*. Thus, we will only need to create three simple image based DeploymentConfigs.

.. code-block:: bash

    oc new-app orders:latest --name orders-staging

.. code-block:: bash

    oc new-app orders:stable --name orders-preprod

.. code-block:: bash

    oc new-app orders:live --name orders-preprod

When planning to run the application, each of these environments would additionally need an associated instance of PostgreSQL. These can easily be created from the official OpenShift template.
