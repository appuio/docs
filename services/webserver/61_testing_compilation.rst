Testing and compilation
=======================

.. note:: This is an early version and still work in progress!

A key feature of our planned pipeline is that there are multiple environments (staging, preprod, prod) where the application should be deployed depending on several criteria. We intentionally left this out until now as we wanted to keep the snippets as small as possible. The following sections will thoroughly describe how to implement the deployment strategy.

The first jobs we are going to extend with our deployment strategy are ``test`` and ``compile``. What we would like to achieve is that code changes on any branch get tested but only changes on the master branch are actually getting compiled. We will implement this by adding the ``only`` directive:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 39-

    stages:
      - build

    variables:
      NODE_VERSION: 6.10-alpine
    
    test:
      stage: build
      image: node:$NODE_VERSION
      script:
        # install necessary application packages
        - yarn install
        # test the application sources
        - yarn test
      cache:
        key: $NODE_VERSION
        paths:
          - node_modules

    compile:
      stage: build
      image: node:$NODE_VERSION
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
        key: $NODE_VERSION
        paths:
          - node_modules
      only:
        - master
        - tags

This defines that the compile job only be run on pushes to master and on tagging any release (which we expect to only happen on master).
