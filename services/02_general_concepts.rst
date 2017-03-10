General Concepts
================

This chapters will introduce some of the most important concepts that you need to know about for the following chapters. We will shortly motivate the concepts and provide you with the most important resources for getting started or deepening your knowledge on your own.


Containers
----------

TODO: improvements

Containers allow us to package everything we need to run our application right alongside the application. They are similar to virtual machines but don't package an entire operating system, which makes them very lightweight. Instead, they build on top of the underlying operating system (most often Linux) and only contain what is specific to the application.

Docker allows us to define what a container should look like using simple configuration files (called Dockerfiles). If we build said configuration files, we get an image that can be run on any machine with the docker binary. The Docker Hub provides access to a vast amount of images that have been created by others and that are ready to be pulled and run.

The main advantage of containers is that they contain everything they need to run, which basically guarantees that they run the same on any machine (in local development as well as in production). This confidence is important if one is considering the usage of fully automated deployment strategies.

**Relevant Readings / Resources**

#. `What is Docker? [Docker Docs] <https://www.docker.com/what-docker>`_
#. `Official Documentation [Docker Docs] <https://docs.docker.com>`_
#. `Dockerfile Reference [Docker Docs] <https://docs.docker.com/engine/reference/builder>`_
#. `Dockerfile Best Practices [Docker Docs] <https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices>`_
#. `Docker Hub <https://hub.docker.com>`_


Continuous Integration
----------------------

TODO: improvements

Modern continuous integration tools enable us to automate many tedious aspects in the software development lifecycle. We can configure these tools such that they automatically perform jobs such as testing and compiling the application and/or deploying a new release.

These tools work especially well if we use them in conjunction with containers, as we can have the tool build a container from our sources, test the container and even directly deploy the new version of the container. As we are confident that containers run the same on all environments, we can trust that the container built and tested in CI will also run where we deployed it to.

There are many CI tools around with all of them providing similar functionalities, which might make choosing between them quite hard. To account for this diversity, we will use two very popular CI tools to continuously integrate our microservices (Jenkins and Gitlab).

**Relevant Readings / Resources**

#. `Continuous Integration [Wikipedia] <https://en.wikipedia.org/wiki/Continuous_integration>`_
#. `Docker for CI/CD <https://www.docker.com/use-cases/cicd>`_


Jenkins
^^^^^^^

TODO: extend once it has been used in the example
TODO: usage with docker? runners useful too?

Jenkins is the most popular open source continuous integration solution. With a vast amount of plugins available, it is extendable to be able to fit almost any use case.

To use Jenkins, you need to create a so called **Jenkinsfile** that specifies all the jobs (the "pipeline") that Jenkins should execute. You also need to add a webhook to your source repository such that Jenkins gets notified on changes to the codebase.

Some real examples on using Jenkins for continuous integration will be presented in the chapters on the Users and Orders services.

**Relevant Readings / Resources**

#. `Getting Started [Jenkins Docs] <https://jenkins.io/doc/pipeline/tour/hello-world>`_
#. `Jenkinsfile [Jenkins Docs] <https://jenkins.io/doc/book/pipeline/jenkinsfile>`_


Gitlab CI
^^^^^^^^^

Gitlab CI is a continuous integration solution that is provided by the popular Git repository manager Gitlab. It is seamlessly integrated into the repository management functionality, which makes its usage very convenient. The downside is that it is only usable if Gitlab is used for repository management. If you use GitHub or similar, you will need to find another solution (Travis CI etc.).

To use Gitlab CI, simply create a **.gitlab-ci.yml** with job definitions and store it in your source repository. Gitlab CI will automatically execute your pipeline on any changes to the codebase.

We will see some examples for using Gitlab CI in the chapters about the Webserver and API services.

**Relevant Readings / Resources**

#. `Quick Start [Gitlab Docs] <https://docs.gitlab.com/ce/ci/quick_start>`_
#. `Config with .gitlab-ci.yml [Gitlab Docs] <https://docs.gitlab.com/ce/ci/yaml>`_


Usage with Docker
"""""""""""""""""

TODO: describe custom runners?

A feature that we find especially useful is that jobs can be run inside a docker container of choice. Instead of having to install dependencies for testing, building etc. inside of our job, we can simply specify a docker image that already includes all those dependencies and execute our job within. This is as easy as using an officially maintained docker image from the hub in many cases.

If we need a very specific configuration or dependencies while executing our job, we can build a tailor-made docker image just for running the job. We will call this process **creating a custom runner** later on in this documentation.

**Relevant Readings / Resources**

#. `Using Docker Images [Gitlab Docs] <https://docs.gitlab.com/ce/ci/docker/using_docker_images.html>`_


OpenShift / Kubernetes
----------------------

* TODO: valid infos?
* TODO: describe APPUiO?

Once you start using containers for more than small demo applications, you are bound to encounter challenges such as scalability and reliability. Docker is a nice tool in itself but as soon as an application consists of several containers that probably depend on each other, a need for orchestration arises.

Orchestrators are pieces of software that have been built to handle exactly those types of problems. An orchestrator organizes multiple services such that they appear as a single service to the outside, allows scaling of those services, handles load-balancing and more. All of this can be done on a single machine as well as on a cluster of servers managed by the orchestrator. A very popular orchestration software is Kubernetes (K8S), which was originally developed by Google.

Adding another layer on top, RedHat OpenShift provides a complete Platform-as-a-Service solution based on Kubernetes. It extends Kubernetes with features for application lifecycle management and DevOps and is easier to get started with. Our public cloud platform APPUiO runs on the OpenShift container platform, which is the enterprise version of OpenShift (with OpenShift Origin as an upstream).

**Relevant Readings / Resources**

#. `User-Guide [Kubernetes Docs] <https://kubernetes.io/docs/user-guide>`_
#. `What is K8S [Kubernetes Docs] <https://kubernetes.io/docs/whatisk8s>`_
#. `Developer Guide [OpenShift Docs] <https://docs.openshift.com/container-platform/3.4/dev_guide/index.html>`_
#. `APPUiO Documentation <http://docs.appuio.ch/en/latest>`_


Source2Image
^^^^^^^^^^^^

* TODO: incremental builds
* TODO: short comparison with normal docker builds and custom runners
* TODO: describe why custom builders will have to be created

Instead of writing a Dockerfile that extends some base image and building it with ``docker build``, OpenShift introduces an alternative way of packaging applications into containers. The paradigm - which they call Source2Image or **S2I** - suggests that given your application's sources and a previously prepared builder image, you inject the sources into the builder container, run an assemble script inside the builder and commit the container. This will have created a runnable version of your application, which you can then start using another command.

This works very well for dynamic languages like Python, where you don't need to compile the application beforehand. The OpenShift Container Platform already provides several such builder images (Python, PHP, Ruby, Node.js etc.), so you would only need to inject your sources and your application container would be ready to run on OpenShift. We will use this strategy for deployment of our Python seervice later on.

For compiled languages like Java, this approach means that the compile-time dependencies would also be included in the runtime image, which could heavily bloat that image and also pose a security risk. S2I allows us to provide a runtime-image, which will be used for running the application after the builder image has assembled it. However, this is not yet reliably implemented in OpenShift (it is still an experimental feature).

There will also be cases where you won't find a S2I builder image that fits your use-case. A possible solution can be to create a custom builder that is tailor-made for the application. We will see how we can create a custom builder in the chapter about our API service.


**Relevant Readings / Resources**

#. `Creating images with S2I [OpenShift Docs] <https://docs.openshift.com/container-platform/3.4/creating_images/s2i.html#creating-images-s2i>`_
#. `Source-to-Image [GitHub] <https://github.com/openshift/source-to-image>`_
#. `Community S2I builder images [GitHub] <https://github.com/openshift-s2i>`_








TODO: reuse this stuff somewhere...
-----------------------------------

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