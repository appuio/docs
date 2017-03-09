Introduction
============

This documentation has been created with the intention of getting developers ready to automatically deploy their apps to the OpenShift container platform. 

We try to achieve this by means of an exemplary microservice application with the basic functionalities of an online shop. Each microservice is continously integrated and deployed to APPUiO (our public OpenShift platform), which allows for an independent description of the necessary pipeline as well as the most relevant concepts for the respective use case.

Before we describe the architecture of our application in more detail, let us shortly summarize what the following chapters will include:

* General Concepts
    * Motivation for Docker and OpenShift/APPUiO
    * Motivation for Continuous integration
    * Overview of CI tooling (Gitlab CI and Jenkins)
    * Overview of Source2Image principles
    * ...
* Webserver
    * Dockerizing a ReactJS application for OpenShift
    * Testing and bundling a ReactJS application
    * Continuous integration with Gitlab CI
    * Deployment strategies with multiple environments
    * Tracking of OpenShift configuration alongside the codebase
    * ...
* API
    * Dockerizing a Scala Play! application
    * Testing and compiling a Scala Play! application
    * Continuous integration with Gitlab CI
    * Using OpenShift Source2Image for building a docker container (including creation of a custom S2I builder)
    * ...
* Users
    * Dockerizing an Elixir application for OpenShift
    * Testing and compiling an Elixir application
    * Continuous integration with Jenkins 2 and the OpenShift plugin
    * ...
* Orders
    * Testing a Python application
    * Continuous integration with Jenkins 2 and the OpenShift plugin
    * Using the OpenShift Python builder for S2I
    * ...
* TBD: Monitoring? Log management? Scalability?
* ...


Architecture of our shop application
------------------------------------

.. image:: architecture.PNG

A first clear distinction in our application's architecture can be made between the frontend and the backend of the application. The frontend only contains a single service, which is the **Webserver**. The Webserver is basically an instance of nginx that serves some static files (our compiled ReactJS application). 

The backend consists of three services: a main endpoint (the **API**) which will be accessed from the frontend of the application, a service that handles user management and authentication (**Users**) and a service that handles order management (**Orders**). Each one of these backend services has access to a separate database for a clean separation of their data.

We tried to account for best practices like the `guidelines for 12-factor apps <https://12factor.net>`_ during development...

TBD...


Where you can find the sources
------------------------------

The sources for all the parts of this documentation as well as for all the described examples can be found on `APPUiO GitHub <https://github.com/appuio>`_. The GitHub repositories are synchronized with our internal development repositories and represent the current state. The following list contains all the public repositories that have been created during the course of writing this documentation:


Documentation
^^^^^^^^^^^^^

* `https://github.com/appuio/docs`_ - Sources for this documentation can be found inside the subdirectory *services*


Microservices
^^^^^^^^^^^^^

* `https://github.com/appuio/shop-example-webserver <https://github.com/appuio/shop-example-webserver>`_ - Webserver
* `https://github.com/appuio/shop-example-api <https://github.com/appuio/shop-example-api>`_ - API
* `https://github.com/appuio/shop-example-users <https://github.com/appuio/shop-example-users>`_ - Users
* `https://github.com/appuio/shop-example-orders <https://github.com/appuio/shop-example-orders>`_ - Orders

Misc
^^^^

* `https://github.com/appuio/shop-example-vagrant <https://github.com/appuio/shop-example-vagrant>`_ - Vagrant box with necessary tools