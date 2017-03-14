Deployment to preprod
=====================

.. note:: This is an early version and still work in progress!

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
        