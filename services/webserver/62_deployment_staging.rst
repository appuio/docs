Deployment to staging
=====================

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
      OC_VERSION: 3.11.0
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