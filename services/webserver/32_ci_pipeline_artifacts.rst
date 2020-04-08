Building the sources
====================

The next step would be that GitLab CI bundles our application sources using Webpack such that they can later be injected into a docker image.

A simple implementation of this job could look as follows:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 5, 7

    compile:
      image: node:6.10-alpine
      script:
        # install necessary application packages
        - yarn install
        # build the application sources
        - yarn build
      cache:
        key: 6.10-alpine
        paths:
          - node_modules

This job would successfully build our application and store a bundle in a directory called *build*. However, GitLab CI doesn't store anything in between jobs, so we would lose access to our bundle after the job finished. We need to explicitly tell GitLab CI that we will need the bundle in the next job (where we will package the application into an image). This is called passing **artifacts** between jobs and will be explained in the following section.


Using build artifacts
"""""""""""""""""""""

If we would like to compile sources in one job and are going to need the compiled applicatiom later on, we will generally need to pass this result as an artifact. We would need to extend our CI configuration as follows:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 8-11

    compile:
      image: node:6.10-alpine
      script:
        # install necessary application packages
        - yarn install
        # build the application sources
        - yarn build
      artifacts:
        expire_in: 5min
        paths:
          - build
      cache:
        key: 6.10-alpine
        paths:
          - node_modules

Using this configuration, GitLab CI would store the bundle for 5 minutes and pass it on to all following jobs in the pipeline. However, if we need artifacts in a job after the next one, we might need to increase the time that GitLab stores the artifacts or they might have been deleted already.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Job Artifacts [GitLab Docs] <https://docs.gitlab.com/ce/user/project/pipelines/job_artifacts.html#defining-artifacts-in-gitlab-ci-yml>`_
