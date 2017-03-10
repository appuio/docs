General Concepts
================

This chapters will introduce some of the most important concepts that you need to know about for the following chapters. We will shortly motivate the concepts and provide you with the most important resources for getting started or deepen your knowledge.


Containers
----------

TODO: needs improvements....

Containers allow us to package everything we need to run our application right alongside the application. Containers are in a way similar to virtual machines but don't package an entire operating system, which makes them very lightweight. Instead, they build on top of the underlying operating system (most often Linux) and only contain application specific libraries.

Docker allows us to define what a container should look like using simple configuration files (called Dockerfiles). If we build said configuration files, we get an image that can be run on any machine that supports docker. Docker also provides a hub with a vast amount of images that have been created by others and that are ready to be pulled and run.

The main advantage of containers is that they contain everything they need to run, which guarantees that they run the same on any machine (in local development as well as in production). This confidence is important if one is considering the usage of completely automated deployment strategies like Continuous Deployment.

**Relevant Readings / Resources**

#. `What is Docker? [Docker Docs] <https://www.docker.com/what-docker>`_
#. `Official Documentation [Docker Docs] <https://docs.docker.com>`_
#. `Dockerfile Reference [Docker Docs] <https://docs.docker.com/engine/reference/builder>`_
#. `Dockerfile Best Practices [Docker Docs] <https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices>`_
#. `Docker Hub <https://hub.docker.com>`_
#. `Docker Source [GitHub] <https://github.com/docker/docker>`_

Continuous Integration
----------------------

* TODO: motivation for CI/CD
* TODO: link to relevant resources


Gitlab CI
^^^^^^^^^

* TODO: short overview
* TODO: explain custom runners


Jenkins
^^^^^^^

* TODO: short overview
* TODO: ...


OpenShift / Kubernetes
----------------------

* TODO: motivation for orchestration / OpenShift
* TODO: describe APPUiO?
* TODO: link to relevant resources


Source2Image
^^^^^^^^^^^^

* TODO: short overview of the concept
    * TODO: incremental builds
* TODO: short comparison with normal docker builds and custom runners
* TODO: show what builder images already exist
* TODO: describe why custom builders will have to be created
* TODO: link to relevant resources





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