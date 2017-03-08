Advanced Deployments
====================

Tracking OpenShift objects
--------------------------

As of now, our DeploymentConfigs, Services, Routes etc. are all managed in OpenShift and can only be changed using OpenShift. Wouldn't it be nice if we could track these objects right alongside our code and redeploy not only the application but also all of its configuration automatically? This section will discuss a possible approach for doing exactly what we described.


Disabling ImageStream triggers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Using default configuration, OpenShift will automatically redeploy to our environments if either the DeploymentConfig is modified or a new image is pushed to the ImageStream (using one of our tracked tags). If we would like to update the DeploymentConfig and push a new image in a single step, this would lead to problems (two deployments would be created, the latter of which would probably fail).

This means that we will need to disable deployment triggers and instead only trigger deployments after we have updated the config as well as the image. To disable said deployment triggers, we need to change the ``triggers`` property in our DeploymentConfigs to the following:

.. code-block:: yaml
    :caption: DC for webserver-staging
    :linenos:
    :emphasize-lines: 5

    triggers:
      -
        type: ImageChange
        imageChangeParams:
          automatic: false
          containerNames:
            - webserver-staging
          from:
            kind: ImageStreamTag
            namespace: vshn-demoapp1c
            name: 'webserver:latest'

This is a workaround, as OpenShift doesn't seem to allow completely disabling deployment triggers at the moment.


Triggering deployments from Gitlab CI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Having completely disabled deployment triggers, we will need to manually trigger a new deployment every time we push a new image to the APPUiO registry. We will do this by adding an ``oc deploy`` command our deployment jobs:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 18

    build-staging:
      environment: webserver-staging
      stage: deploy-staging
      image: registry.vshn.net/roland.schlaefli/docs_runner_oc:$OC_VERSION
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
        # trigger a deployment
        - oc deploy webserver-staging --latest --follow
      only:
        - master
      except:
        - tags

The ``--follow`` flag in the snippet above allows us to track the progress of the deployment right inside of Gitlab CI (it streams the deployment logs).


Exporting configuration objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to add the configuration objects to our repository, we first need to export them from APPUiO. This can be achieved using the ``oc export`` command on our *staging* environment as follows:

.. code-block:: yaml

    $ oc export dc,svc,route webserver-staging
    - apiVersion: v1
      kind: DeploymentConfig
      metadata:
        ...
      spec:
        ...
      status:
        ...
    - apiVersion: v1
      kind: Service
      metadata:
        ...
      spec:
        ...
      status:
        ...
    - apiVersion: v1
      kind: Route
      metadata:
        ...
      spec:
        ...
      status:
        ...

We can now save those configuration objects to separate files in our repository (*deployment.yaml*, *service.yaml*, *route.yaml*). ``status:`` and its children can be removed while saving, as this represents the current status of the respective object which is dynamically generated. For the sake of simplicity, we will only track DeploymentConfig, Service and Route in our source control.


Replacing configuration objects using CI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now that our configuration objects are tracked inside our repository (in docker/openshift/...yaml), we can automatically update the configuration in OpenShift whenever we push a new image. We will then start a new deployment only after the image has been pushed and the new configuration has been updated.

OpenShift allows us to either ``oc replace`` an entire configuration object or to ``oc apply`` changes to an existing object (which will merge those changes into the existing file). As we track the entire file in our repository and will not want to modify the configuration anywhere but the repository, we will use *replace* in our approach.


Staging
"""""""

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 16

    build-staging:
      environment: webserver-staging
      stage: deploy-staging
      image: registry.vshn.net/roland.schlaefli/docs_runner_oc:$OC_VERSION
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
        # update the configuration in OpenShift
        - oc replace -f docker/openshift -R
        # push the image to the internal registry
        - docker push $OC_REGISTRY_IMAGE:latest
        # trigger a deployment
        - oc deploy webserver-staging --latest --follow
      only:
        - master
      except:
        - tags

The ``oc replace -f docker/openshift -R`` command will look for configuration objects in our *docker/openshift* directory and recursively replace all of them on APPUiO. Any changes we might have made using either the CLI or the Web-Interface would be overwritten.

This job will successfully deploy a new configuration and image to the staging environment (as we exported them from the staging environment, their metadata ties them to staging). However, we want to deploy the exact same configuration to the preprod and prod environment. In order to do this, we would either have to track the configuration file once per environment or dynamically modify their metadata at runtime of the job.


Preprod and prod
""""""""""""""""

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 16

    build-preprod:
      environment: webserver-preprod
      stage: deploy-preprod
      image: registry.vshn.net/roland.schlaefli/docs_runner_oc:$OC_VERSION
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
        # update the configuration in OpenShift
        - sed -i 's;webserver-staging;webserver-preprod;g' docker/openshift/*
        - sed -i 's;webserver:latest;webserver:stable;g' docker/openshift/*
        - sed -i 's;172.30.215.173;172.30.29.25;g' docker/openshift/*
        - oc replace -f docker/openshift -R
        # push the image to the internal registry
        - docker push $OC_REGISTRY_IMAGE:stable
        # trigger a deployment
        - oc deploy webserver-preprod --latest --follow
      only:
        - tags



TODO: adding health checks

TODO: managing resource quotas
