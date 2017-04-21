Variables & Parallelization
===========================

.. note:: This is an early version and still work in progress!

Now that we have jobs that test and bundle our application, we can combine them and apply some performance and maintanability optimizations along the way.

We can optimize the performance of these jobs by running them in parallel instead of sequentially (given appropriate system-side concurrency settings). This will shorten the time our entire pipeline needs to finish. Gitlab CI will run jobs in parallel if they are defined to be in the same *stage*.

To optimize maintainability of our CI configuration, we can use variables for configuration values like cache directories and image versions. This allows us to specify the value a single time instead of specifying it in each job.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 1-2, 4-6, 9, 21

    stages:
      - build

    variables:
      NODE_VERSION: 6.10-alpine

    test:
      stage: build
      image: node:$NODE_VERSION
      script:
        - yarn install
        ...
      cache:
        key: $NODE_VERSION
        paths:
          - node_modules

    compile:
      stage: build
      image: node:$NODE_VERSION
      script:
        - yarn install
        ...
      cache:
        key: $NODE_VERSION
        paths:
          - node_modules
      ...

We now have a nicely working and quite performant Gitlab CI pipeline with test and compile jobs running in parallel. We are ready to package the application into a container and deploy that container to APPUiO. The next section will show how we can dockerize an application with Gitlab CI while a detailed description of our deployment strategy will follow later on.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Variables [Gitlab Docs] <https://docs.gitlab.com/ce/ci/variables>`_