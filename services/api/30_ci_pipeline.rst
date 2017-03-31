Implementing a CI pipeline
=========================

.. note:: This is an early version and still work in progress!

.. image:: api_pipeline.PNG

.. todo::
    * explain how to implement the test step in Gitlab CI
    * explain how to trigger the S2I build from Gitlab CI

The CI pipeline for the API service will look a lot like the pipeline we have built for the webserver in the previous chapter. It will differ in specific implementation details (using SBT instead of Yarn etc.) and there won't be any compilation or pushes to the APPUiO registry, which makes the entire pipeline much more compact.

Instead of pushing to the APPUiO registry, the deploy jobs will trigger S2I builds on APPUiO. APPUiO will then grab the sources from our repository and build the service using our custom S2I builder. The necessary steps to setup APPUiO appropriately will be discussed in later sections, the current section will focus on the Gitlab CI side of things.

.. note::

    We will again deploy to three different environments (staging, preprod and prod) but won't go into much detail about this as deploying to multiple environments has been thoroughly discussed in the previous chapter.


Running tests
-------------

The first step to our CI pipeline will again be running all the tests our application provides. This is a pattern we will adhere to in all of our pipelines (as we have in the webserver chapter). Testing the application as one of the first steps in the pipeline guarantees a quick feedback loop and prevents us from deploying code that could break the application.

The following CI configuration snippet will run tests for our Scala application (including caching and usage of variables): 

.. code-block:: yaml
    :caption: gitlab-ci.yml

    stages:
      - build

    variables:
      SBT_CACHE: ".ivy"
      SBT_VERSION: 0.13.13

    test:
      image: appuio/gitlab-runner-sbt:$SBT_VERSION
      stage: build
      script:
        # test the application with SBT
        - sbt -ivy "$SBT_CACHE" test 
        # print the disk usage of the .ivy folder
        - du -sh "$SBT_CACHE"
      cache:
        key: "$CI_PROJECT_ID"
        paths:
          - "$SBT_CACHE"
    
Preparing APPUiO for S2I
-----------------------

.. todo::
    * Describe how to prepare APPUiO in a separate section?

    
Deployment to APPUiO
--------------------

.. todo::
    * Describe the commands specific to S2I

.. code-block:: yaml

    stages:
      - build
      - deploy-staging
      - deploy-preprod
      - deploy-prod

    variables:
      CLUSTER_IP_STAGING: 172.30.216.216
      OC_VERSION: 1.3.3
      SBT_CACHE: ".ivy"
      SBT_VERSION: 0.13.13

    .oc: &oc
      image: appuio/gitlab-runner-oc:$OC_VERSION
      script: &oc_script
        # login to the service account to get access to the CLI
        - oc login $KUBE_URL --token=$KUBE_TOKEN
        # promote the image
        - oc tag api:$BASE_TAG api:$DEPLOY_TAG
        # update the configuration in OpenShift
        - sed -i 's|PLAY_SECRET_PLACEHOLDER|'"$PLAY_SECRET"'|g' docker/openshift/*
        - sed -i 's;api-staging;api-'$DEPLOY_ENV';g' docker/openshift/*
        - sed -i 's;api:latest;api:'$DEPLOY_TAG';g' docker/openshift/*
        - sed -i 's;'$CLUSTER_IP_STAGING';'$CLUSTER_IP';g' docker/openshift/*
        - oc replace -f docker/openshift -R
        # trigger a deployment
        - oc deploy api-$DEPLOY_ENV --latest --follow

    test:
      ...

    build-staging:
      <<: *oc
      environment: api-staging
      stage: deploy-staging
      script:
        # login to the service account to get access to the CLI
        - oc login $KUBE_URL --token=$KUBE_TOKEN
        # start a new build for staging environment on every push to master
        - oc start-build api --follow
        # update the configuration in openshift
        - sed -i 's|PLAY_SECRET_PLACEHOLDER|'"$PLAY_SECRET"'|g' docker/openshift/*
        - oc replace -f docker/openshift -R
        # trigger a deployment
        - oc deploy api-staging --latest --follow
      only:
        - master
      except:
        - tags

    build-preprod:
      <<: *oc
      ...

    build-prod:
      <<: *oc
      ...
