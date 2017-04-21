Using caching
=============

.. note:: This is an early version and still work in progress!

The solution to this is called **caching** (in Gitlab CI as well as in other CI tools). Gitlab CI allows us to store (*cache*) directories inside the project's scope after a job has finished and restore them to the same location before any subsequent run of the same job. This can be used to cache the downloaded NPM packages and restore them such that they don't have to be downloaded every time.

The following snippet shows how we could update the configuration to introduce caching with Yarn:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 9, 11

    test:
      image: node:6.10-alpine
      script:
        # install necessary application packages
        - yarn install
        # test the application sources
        - yarn test
      cache:
        key: 6.10-alpine
        paths:
          - node_modules

This configuration will tell Gitlab CI that it should cache the files inside the *node_modules* directory between subsequent runs. Also, setting *key* to a constant value allows us to use the same cache no matter what branch we are on. We set it to the respective name of the NodeJS image as we want to invalidate the cache when we upgrade to a newer version.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Caching [Gitlab Docs] <https://docs.gitlab.com/ce/ci/yaml/#cache>`_