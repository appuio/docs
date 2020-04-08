Building a container
====================

Generally, building docker images inside of GitLab CI is quite easy. The snippet below shows a very simple - but working - docker build inside of GitLab CI. It includes logging in to Docker Hub, building and tagging the image as ``appuio/docs-webserver:latest`` and pushing it to Docker Hub.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 4-5

    build:
      stage: deploy
      image: docker:latest
      services:
        - docker:dind
      script:
        - docker login -u $USERNAME -p $PASSWORD
        - docker build . -t appuio/docs-webserver:latest
        - docker push appuio/docs-webserver:latest

The most crucial part for this to work is the inclusion of ``docker:dind`` as a service, as it provides the docker daemon that all the docker commands will use. The image we use to run the commands is simply the official docker image (it includes the docker binary). ``$USERNAME`` and ``$PASSWORD`` are GitLab CI variables that are injected at runtime (it is generally bad practice to hardcode login details in a file inside a repository).


Using cache-from
""""""""""""""""

GitLab CI doesn't allow keeping the docker build cache (cached layers) as it is located outside the build context. There are various ways to circumvent this, but docker version 1.13 introduced a very nice new feature which helps in that regard.

As of 1.13, docker offers the possibility to take an existing image and use its layers as the cache for a new build. This can be achieved by pulling the image we would like to use as cache and using the flag ``--cache-from`` when running ``docker build``. Pulling the image obviously costs some time, but it is nevertheless useful in many cases.

If we extend our snippet with these findings in mind, it would look as follows:

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 8-9

    build:
      stage: deploy
      image: docker:latest
      services:
        - docker:dind
      script:
        - docker login -u $USERNAME -p $PASSWORD
        - docker pull appuio/docs-webserver:latest
        - docker build . --cache-from=appuio/docs-webserver -t appuio/docs-webserver
        - docker push appuio/docs-webserver:latest

This would already work for a successful deployment to APPUiO as the OpenShift platform can get its images directly from Docker Hub. However, if we want to take full advantage of GitLab CI and the internal APPUiO registry, we will need some further configuration. More about this will be explained in one of the following sections.

.. admonition:: Disclaimer
  :class: warning

  Building (with) docker images inside of GitLab CI generally requires some more preparations and system side configurations. We will assume that your GitLab instance has already been correctly installed and configured, as system setup would be out of scope for this documentation.
