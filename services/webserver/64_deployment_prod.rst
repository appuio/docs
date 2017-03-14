Deployment to prod
==================

.. note:: This is an early version and still work in progress!

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
      