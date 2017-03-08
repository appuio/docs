Implementing a deployment strategy
==================================

A key feature of our planned pipeline is that there are multiple environments (staging, preprod, prod) where the application should be deployed depending on several criteria. We intentionally left this out until now as we wanted to keep the snippets as small as possible. This section will thoroughly describe how to implement the deployment strategy.


Testing and compilation
^^^^^^^^^^^^^^^^^^^^^^^

The first jobs we are going to extend with our deployment strategy are ``test`` and ``compile``. What we would like to achieve is that code changes on any branch get tested but only changes on the master branch are actually getting compiled. We will implement this by adding the ``only`` directive:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 39-

    stages:
      - build

    variables:
      NODE_VERSION: 6.10-alpine
      YARN_CACHE: .yarn

    test:
      stage: build
      image: node:$NODE_VERSION
      script:
        # install necessary application packages
        - yarn install --cache-folder="$YARN_CACHE"
        # test the application sources
        - yarn test
      cache:
        key: $CI_PROJECT_ID
        paths:
          - $YARN_CACHE
          - node_modules

    compile:
      stage: build
      image: node:$NODE_VERSION
      script:
        # install necessary application packages
        - yarn install --cache-folder="$YARN_CACHE"
        # build the application sources
        - yarn build
      artifacts:
        expire_in: 5min
        paths:
          - build
      cache:
        key: $CI_PROJECT_ID
        paths:
          - $YARN_CACHE
          - node_modules
      only:
        - master
        - tags

This defines that the compile job only be run on pushes to master and on tagging any release (which we expect to only happen on master).


Deployment to staging
^^^^^^^^^^^^^^^^^^^^^

Next up is adding a deployment to the staging environment, which includes building a docker image and pushing it to the APPUiO registry.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 3, 26-27, 30-

    stages:
      - build
      - deploy-staging

    variables:
      OC_REGISTRY_URL: registry.appuio.ch
      OC_REGISTRY_IMAGE: $OC_REGISTRY_URL/$KUBE_NAMESPACE/webserver
      OC_VERSION: 1.3.3
      ...

    test: ...
    compile: ...

    build-staging:
      environment: webserver-staging
      stage: deploy-staging
      image: appuio/gitlab-runner-oc:$OC_VERSION
      services:
        - docker:dind
      script:
        # login to the service account to get access to the internal registry
        - oc login $KUBE_URL --token=$KUBE_TOKEN
        - docker login -u serviceaccount -p `oc whoami -t` $OC_REGISTRY_URL
        # build the docker image and tag it as latest
        # use the current latest image as a caching source
        - docker pull $OC_REGISTRY_IMAGE:latest
        - docker build --cache-from $OC_REGISTRY_IMAGE:latest -t $OC_REGISTRY_IMAGE:latest .
        # push the image to the internal registry
        - docker push $OC_REGISTRY_IMAGE:latest
      only:
        - master
      except:
        - tags        

We added both the directives ``only`` and ``except`` in this step, as we want to run ``build-staging`` only for events on master, except if that event is tagging a release.


Deployment to preprod
^^^^^^^^^^^^^^^^^^^^^

The job for deploying to preprod will be exactly the same as the job for staging, except that it will only run on tags and that it will tag images as *stable* instead of *latest*. Also, the ``--cache-from`` flag will still use the *latest* image as *stable* will probably be heavily outdated at the time of building a new stable release.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 4, 23-24, 27-

    stages:
        - build
        - deploy-staging
        - deploy-preprod

    variables: ...
    test: ...
    compile: ...
    build-staging: ...

    build-preprod:
      environment: webserver-preprod
      stage: deploy-preprod
      image: appuio/gitlab-runner-oc:$OC_VERSION
      services:
        - docker:dind
      script:
        # login to the service account to get access to the internal registry
        - oc login $KUBE_URL --token=$KUBE_TOKEN
        - docker login -u serviceaccount -p `oc whoami -t` $OC_REGISTRY_URL
        # build the docker image and tag it as stable
        # use the current latest image as a caching source
        - docker pull $OC_REGISTRY_IMAGE:latest
        - docker build --cache-from $OC_REGISTRY_IMAGE:latest -t $OC_REGISTRY_IMAGE:stable .
        # push the image to the internal registry
        - docker push $OC_REGISTRY_IMAGE:stable
      only:
        - tags


Deployment to prod
^^^^^^^^^^^^^^^^^^

The final step in our pipeline is the deployment to production (aka "going live"). As this is critical, the job should only be run after it has been manually triggered, which is why we introduce ``when: manual``. The deployment will then have to be triggered from the Gitlab UI.

Another important difference is that this job doesn't actually build an image: it reuses the image that has been deployed to preprod and just adds the tag *live* to this image ``oc tag xyz:stable xyz:live``. This corresponds to best practice as another build could possibly result in a different version of the image. We always want preprod and prod environment to be based on exactly the same image.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 5, 21-

    stages:
      - build
      - deploy-staging
      - deploy-preprod
      - deploy-prod

    variables: ...
    test: ...
    compile: ...
    build-staging: ...
    build-preprod: ...

    build-prod:
      environment: webserver-prod
      stage: deploy-prod
      image: appuio/gitlab-runner-oc:$OC_VERSION
      script:
        # login to the service account to get access to the CLI
        - oc login $KUBE_URL --token=$KUBE_TOKEN
        # tag the current stable image as live
        - oc tag webserver:stable webserver:live
      only:
        - tags
      when: manual


Creating deployments in APPUiO
------------------------------

Now that we have an ImageStream for pushing to and a Gitlab CI configuration that pushes to that stream, we need to tell APPUiO what it should actually do with those incoming image pushes. This can be achieved by creating a **DeploymentConfig (DC)**, specifying the respective image tag as a source for a deployment.

Before we go on, we want to make sure that we have pushed to each environment **at least once**. This creates the respective tag in the ImageStream and allows us to easily create DeploymentConfigs in the next section.


Creating DeploymentConfigs
^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^

After the deployment has successfully finished, our webserver should be running inside a pod in the staging environment. However, to make it accessible to the outside world, we still have to create a **Route**. The following command will create a Route that redirects HTTPS requests to our webserver's port 9000.

.. code-block:: yaml

    $ oc create route edge webserver-staging --service=webserver-staging --port=9000
    route "webserver-staging" created

The newly created Route will be accessible on a url similar to **https://webserver-staging-yourproject.appuioapp.ch** and our webserver should finally be accessible.

We now have a working CI pipeline and working deployments on OpenShift. This could in theory already conclude our explanations about the webserver service. We would, however, still like to introduce some more advanced concepts like tracking the OpenShift configuration objects in our repository. The next and last section about this service will thus be dedicated to these topics.

**Relevant Readings / Resources**

#. `Creating New Applications [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/dev_guide/application_lifecycle/new_app.html>`_
#. `Deployments [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/dev_guide/deployments/how_deployments_work.html>`_
