Creating deployments in APPUiO
==============================

.. note:: This is an early version and still work in progress!

Now that we have an ImageStream for pushing to and a Gitlab CI configuration that pushes to that stream, we need to tell APPUiO what it should actually do with those incoming image pushes. This can be achieved by creating a **DeploymentConfig (DC)**, specifying the respective image tag as a source for a deployment.

Before we go on, we want to make sure that we have pushed to each environment **at least once**. This creates the respective tag in the ImageStream and allows us to easily create DeploymentConfigs in the next section.


Creating DeploymentConfigs
--------------------------

Creating basic DeploymentConfigs for our webserver is quite easy, as it doesn't depend on any other service (like a database). We can create a DC for the staging environment as follows:

.. code-block:: yaml
    :emphasize-lines: 6, 9, 10

    $ oc new-app -i webserver:latest --name webserver-staging
    --> Found image 217d39f in image stream webserver under tag "latest" for "webserver:latest"

        * This image will be deployed in deployment config "webserver-staging"
        * Ports 443/tcp, 80/tcp, 9000/tcp will be load balanced by service "webserver-staging"
        * Other containers can access this service through the hostname "webserver-staging"

    --> Creating resources with label app=webserver-staging ...
        deploymentconfig "webserver-staging" created
        service "webserver-staging" created
    --> Success
        Run 'oc status' to view your app.

This will have created a **DeploymentConfig** and a **Service** for our staging environment. Simply put, a Service is a load balancer that exposes an application firstly using a unique cluster ip and secondly using its name. A DeploymentConfig is the highest configuration layer on a per-application basis (defines number of replicas, health checks, resource limits etc.). We will cover some of the concepts of DC's but suggest you also refer to the official docs for more details (see #1 and #2).

Having created a DeploymentConfig, APPUiO will immediately deploy the image specified and will redeploy on each image push (by default).


Creating a route
----------------

After the deployment has successfully finished, our webserver should be running inside a pod in the staging environment. However, to make it accessible to the outside world, we still have to create a **Route**. The following command will create a Route that redirects HTTPS requests to our webserver's port 9000.

.. code-block:: yaml

    $ oc create route edge webserver-staging --service=webserver-staging --port=9000
    route "webserver-staging" created

The newly created Route will be accessible on a url similar to **https://webserver-staging-yourproject.appuioapp.ch** and our webserver should finally be accessible.

We now have a working CI pipeline and working deployments on OpenShift. This could in theory already conclude our explanations about the webserver service. We would, however, still like to introduce some more advanced concepts like tracking the OpenShift configuration objects in our repository. The next and last section about this service will thus be dedicated to these topics.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Creating New Applications [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/dev_guide/application_lifecycle/new_app.html>`_
    #. `Deployments [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/dev_guide/deployments/how_deployments_work.html>`_
