General Concepts
================

This chapter will introduce some of the most important concepts that you need to know about for the following chapters. We will shortly motivate the concepts and provide you with the most relevant resources for getting started or deepening your knowledge on your own.

Containers
----------

Containers allow us to package everything we need to run our application right alongside the application. They are similar to virtual machines but don't package an entire operating system, which makes them very lightweight. Instead, they build on top of the underlying operating system (most often Linux) and only contain what is specific to the application.

Docker allows us to define what a container should look like using simple configuration files (called Dockerfiles). If we build said configuration files, we get an image that can be run on any machine with the docker binary. The Docker Hub provides access to a vast amount of images that have been created by others and that are ready to be pulled and run.

The main advantage of containers is that they contain everything they need to run, which guarantees that they run the same on any machine (in local development as well as in production). This confidence is crucial if one is considering the usage of fully automated deployment strategies like Continuous Deployment.


.. admonition:: Relevant Readings / Resources
    :class: note

    #. `What is Docker? [Docker Docs] <https://www.docker.com/what-docker>`_
    #. `Official Documentation [Docker Docs] <https://docs.docker.com>`_
    #. `Dockerfile Reference [Docker Docs] <https://docs.docker.com/engine/reference/builder>`_
    #. `Dockerfile Best Practices [Docker Docs] <https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices>`_
    #. `Docker Hub <https://hub.docker.com>`_


Docker Compose
^^^^^^^^^^^^^^

Most of the time, an application will depend on other containers like databases, caches or other microservices. To be able to coordinate the application and its dependencies while developing locally, we can leverage Docker and the **Docker Compose** toolkit.

Docker Compose allows us to set up an overall service definition that can contain many interdependent services. The service definition is saved in a **docker-compose.yml** file that can then be tracked alongside the source code.

A service definition might look as follows:

.. code-block:: yaml
    :linenos:

    version: "2.1"
    services:
      # definition for the users service
      users:
        # build the Dockerfile in the current directory
        build: .
        # specify environment variables for the users service
        environment:
          SECRET_KEY: "abcd"
        # specify ports that the users service should publish
        ports:
          - "4000:4000"

      # definition for the associated database
      users-db:
        # specify the image the users-db should run
        image: postgres:9.5-alpine
        # specify environment variables for the users-db service
        environment:
          POSTGRES_USER: users
          POSTGRES_PASSWORD: secret

On running ``docker-compose up --build``, this configuration will build the users service and pull the PostgreSQL database image. It will then start up both services and expose them with their hostname corresponding to their name in the service definition. This means that the *users* service can connect to the database using the hostname *users-db*.

We provide such docker-compose configuration files for every service independently as well as in the form of an umbrella docker-compose file that allows to start-up the entire application. The umbrella can be found on `<https://github.com/appuio/shop-example>`_. Please make sure also to include the submodules (i.e. using ``git clone --recursive -j8 https://github.com/appuio/shop-example``).

.. note::
    A problem with such simple configurations is that the database usually performs an initialization process before starting up (creating indices etc.). If both services are started simultaneously, the users service will be unable to connect to the database.

    To circumvent this, we need to have the users service wait for the database to finish its initialization. This topic will be addressed in later chapters, as it will not only matter in local development but also once the services are deployed.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Overview of Docker Compose [Docker Docs] <https://docs.docker.com/compose/overview>`_


Continuous Integration
----------------------

Modern continuous integration tools enable us to automate many tedious aspects of the software development lifecycle. We can configure these tools such that they automatically perform jobs like testing and compiling the application and deploying a new release.

These tools work especially well if we use them in conjunction with containers, as we can have the tool build a container from our sources, test the container and possibly directly deploy the new version of the container. As we are confident that containers run the same on all environments, we can trust that the container built and tested in CI will also run where we deployed it to.

There are many CI tools around with all of them providing similar functionalities, which might make choosing between them quite hard. To account for this diversity, we will use two very popular CI tools to continuously integrate our microservices: Jenkins and GitLab.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Continuous Integration [Wikipedia] <https://en.wikipedia.org/wiki/Continuous_integration>`_
    #. `Docker for CI/CD <https://www.docker.com/use-cases/cicd>`_


Jenkins
^^^^^^^

Jenkins is the most popular open-source continuous integration solution. With a vast amount of plugins available, it is extendable to be able to fit almost any use case.

To use Jenkins, you need to create a so-called **Jenkinsfile** that specifies all the jobs (the "pipeline") that Jenkins should execute. You also need to add a webhook to your source repository such that Jenkins gets notified on changes to the codebase.

A real example on using Jenkins for continuous integration will be presented in the chapter on the **Orders** microservice.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Getting Started [Jenkins Docs] <https://jenkins.io/doc/pipeline/tour/hello-world>`_
    #. `Jenkinsfile [Jenkins Docs] <https://jenkins.io/doc/book/pipeline/jenkinsfile>`_


GitLab CI
^^^^^^^^^

GitLab CI is a continuous integration solution that is provided by the popular Git repository manager GitLab. It is seamlessly integrated into the repository management functionality, which makes its usage very convenient. The downside is that it is only usable if GitLab is used for repository management. If you use GitHub or similar, you will need to find another solution (Jenkins, Travis CI, etc.).

To use GitLab CI, simply create a **.gitlab-ci.yml** with job definitions and store it in your source repository. GitLab CI will automatically execute your pipeline on any changes to the codebase.

We will see examples for using GitLab CI in the chapters about the **Webserver**, **API** and **Users** services.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Quick Start [GitLab Docs] <https://docs.gitlab.com/ce/ci/quick_start>`_
    #. `Config with .gitlab-ci.yml [GitLab Docs] <https://docs.gitlab.com/ce/ci/yaml>`_


Usage with Docker
"""""""""""""""""

A feature that we find especially useful is that jobs can be run inside a Docker container. Instead of having to install dependencies for testing, building, etc. during execution of our job, we can simply specify a docker image that already includes all those dependencies and execute the job within this image. In many cases, this is as easy as using an officially maintained docker image from the Hub.

If we need a very specific configuration or dependencies while executing our job, we can build a tailor-made docker image just for running the job. We will describe how to **create a custom runner** later on in this documentation.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Using Docker Images [GitLab Docs] <https://docs.gitlab.com/ce/ci/docker/using_docker_images.html>`_


OpenShift / Kubernetes
----------------------

Once you start using containers for more than small demo applications, you are bound to encounter challenges such as scalability and reliability. Docker is an excellent tool in itself, but as soon as an application consists of several containers that probably depend on each other, a need for orchestration arises.

Orchestrators are pieces of software that have been built to handle exactly those types of problems. An orchestrator organizes multiple services such that they appear as a single service to the outside, allows scaling of those services, handles load-balancing and more. All of this can be done on a single machine as well as on a cluster of servers. A very popular orchestration software is Kubernetes (K8S), which was originally developed by Google.

Adding another layer on top, RedHat OpenShift provides a complete Platform-as-a-Service solution based on Kubernetes. It extends Kubernetes with features for application lifecycle management and DevOps and is easier to get started with. Our public cloud platform APPUiO runs on the OpenShift container platform, which is the enterprise version of OpenShift (with OpenShift Origin as an upstream).

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `User-Guide [Kubernetes Docs] <https://kubernetes.io/docs/user-guide>`_
    #. `What is K8S [Kubernetes Docs] <https://kubernetes.io/docs/whatisk8s>`_
    #. :openshift:`Developer Guide [OpenShift Docs] <dev_guide/index.html>`
    #. `APPUiO Documentation <http://docs.appuio.ch/en/latest>`_
    #. `OpenShift Origin [GitHub] <https://github.com/openshift/origin>`_

Source2Image
^^^^^^^^^^^^

Instead of writing a Dockerfile that extends some base image and building it with ``docker build``, OpenShift introduces an alternative way of packaging applications into containers. The paradigm - which they call Source2Image or short **S2I** - suggests that given your application's sources and a previously prepared builder image, you inject the sources into the builder container, run an assemble script inside the builder and commit the container. This will have created a runnable version of your application, which you can run using another command.

This works very well for dynamic languages like Python where you don't need to compile the application beforehand. The OpenShift Container Platform already provides several such builder images (Python, PHP, Ruby, Node.js, etc.) so you would only need to inject your sources and your application would be ready to run. We will use this strategy for deployment of our Python microservice later on.

For compiled languages like Java, this approach means that the compile-time dependencies would also be included in the runtime image, which could heavily bloat that image and pose a security risk. S2I would allow us to provide a runtime image for running the application after the builder image has assembled it. However, this is not yet fully implemented in OpenShift (it is still an experimental feature).

There will also be cases where you can't find an S2I builder image that fits your use-case. A possible solution can be to create a custom builder that is tailor-made for the application. We will see how we can use such a custom builder in the chapter about the **API** service.


.. admonition:: Relevant Readings / Resources
    :class: note

    #. :openshift:`Creating images with S2I [OpenShift Docs] <creating_images/s2i.html#creating-images-s2i>`
    #. `Source-to-Image [GitHub] <https://github.com/openshift/source-to-image>`_
    #. `Community S2I builder images [GitHub] <https://github.com/openshift-s2i>`_
