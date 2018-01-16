Deploying to APPUiO
===================

As we now have a working Gitlab CI pipeline, we need to setup APPUiO such that Gitlab CI can actually push images and trigger deployments. We have already covered this in depth for the webserver service and as such will only shortly go through the respective commands in this section.

Setting up an ImageStream
-------------------------

To allow our CI pipeline to push images to APPUiO, we will have to create an ImageStream:

.. code-block:: bash

    $ oc create is users
    imagestream "users" created

This will allow the pipeline to push arbitrary tags to an ImageStream called ``users``. We are going to use the tags *latest*, *stable* and *live* for *staging*, *preprod* and *prod* environments respectively. These tags don't have to be created beforehand, they will be created on the first push to the ImageStream.

After having added the ImageStream, make sure to run each the pipeline at least once for each environment. This will make sure that the tags are appropriately populated with images such that we can deploy the images on OpenShift.


Creating DeploymentConfigs
--------------------------

We should now have an ImageStream with images for the tags *latest*, *stable* and *live*. This allows us to create DeploymentConfigs as follows:

.. code-block:: bash

    $ oc new-app users:latest --name users-staging
    --> Found image in image stream "app/users" under tag "latest" for "users:latest"

        * This image will be deployed in deployment config "users-staging"
        * Port 4000/tcp will be load balanced by service "users-staging"
        * Other containers can access this service through the hostname "users-staging"

    --> Creating resources ...
        deploymentconfig "users-staging" created
        service "users-staging" created
    --> Success
        Run 'oc status' to view your app.

    $ oc new-app users:stable --name users-preprod
    ...

    $ oc new-app users:prod --name users.prod
    ...

These deployments should immediately launch pods that expose the *users* API as a service. The users microservice is a backend service, which means that it won't need to be (and shouldn't be) publicly exposed using a route. The API microservice will be the only entity that connects to the users API.
