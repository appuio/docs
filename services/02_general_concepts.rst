General Concepts
================

.. TODO: explain our Vagrant box

You can build this box using the Vagrantfile in the ``docs_vagrant`` repository (make sure to adjust the path to your repositories in the Vagrantfile). If you are not familiar with Vagrant please refer to the official documentation at #2.

After you have successfully built our Vagrant box and started it using ``vagrant up``, open an SSH connection using ``vagrant ssh``. Change into the directory for ``docs_webserver`` and you are ready to go.

**Relevant Readings / Resources**

* `#1 - Atlas Box Repository [Vagrant] <https://atlas.hashicorp.com/boxes/search>`_
* `#2 - Getting Started [Vagrant] <https://www.vagrantup.com/docs/getting-started>`_

What we left out of scope up in up to this point is the usage of a custom image ("runner") for running the job (as specified in line 6). This will be discussed in detail in the next chapter.

Using custom runners
""""""""""""""""""""

If we add a statement like ``image: node:6.10-alpine`` to our job, we tell Gitlab that it shouldn't run the commands inside the normal runtime environment (a basic docker container) but instead pull an arbitrary image and run the commands in there. This means that we can run our scripts with images that already include packages like Yarn or NPM and that we don't necessarily have to install those ourselves.

We find that building a custom runner with the needed test/build/compile dependencies (or just using some official image where those dependencies are installed) is worth the initial investment of building the runner, as each job run with the runner takes much less time.

In essence, the custom runner for the webserver has to include Yarn and its dependencies NodeJS/NPM such that we can test and build our application's sources. The following Dockerfile shows how easy it can be to build a custom runner:

literalinclude:: ../runner_yarn/Dockerfile
    :language: docker
    :caption: docs_runner_yarn/Dockerfile
    :name: docs_runner_yarn/Dockerfile
    :linenos:

After you have built this Dockerfile and pushed the image to either the Docker Hub or your internal Gitlab CI registry, you can use it as a runner by specifying it within an ``image: ...`` clause. Feel free to use or extend the version we provided on Docker Hub at ``appuio/gitlab-runner-yarn``.

**Relevant Readings / Resources**

* `#2 - Using Docker Images [Gitlab Docs] <https://docs.gitlab.com/ce/ci/docker/using_docker_images.html#using-docker-images>`_