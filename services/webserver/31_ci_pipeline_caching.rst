Using caching
=============

.. note:: This is an early version and still work in progress!

The solution to this is called **caching** (in Gitlab CI as well as in other CI tools). Gitlab CI allows us to store (*cache*) directories inside the project's scope after a job has finished and restore them to the same location before any subsequent run of the same job. This can be used to cache the downloaded NPM packages and restore them such that they don't have to be downloaded every time.

To get this to work with Yarn and some other build tools, they have to be configured appropriately. Yarn would normally cache packages in the user's home directory, such that the cache can also be used in any other project the user might have. However, Gitlab CI doesn't allow us to cache directories outside of a project's scope. This means that we have to specify a directory in scope where Yarn can store its cache. 

We can achieve this by using the ``--cache-folder=`` flag on our ``yarn install`` command. Yarn will store its cache in the specified directory and recognize those cached packages on ``yarn install`` in subsequent runs. It will only download updates for outdated packages.

The following snippet shows how we could update the configuration to introduce caching with Yarn:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 5, 8-

    test:
      image: node:6.10-alpine
      script:
        # install necessary application packages
        - yarn install --cache-folder=".yarn"
        # test the application sources
        - yarn test
      cache:
        key: $CI_PROJECT_ID
        paths:
          - .yarn
          - node_modules

This configuration will tell Gitlab CI that it should cache the files inside the *.yarn* and *node_modules* directories between subsequent runs. Also, setting *key* to a constant value allows us to use the same cache no matter what branch we are on.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Caching [Gitlab Docs] <https://docs.gitlab.com/ce/ci/yaml/#cache>`_