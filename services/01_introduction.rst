Introduction
============

* TODO: review list after writing respective chapters

This documentation has been created with the intention of getting developers ready to automatically deploy their apps to the OpenShift container platform. 

We try to achieve this by means of an exemplary microservice application with the basic functionalities of an online shop. Each microservice is continously integrated and deployed to `APPUiO <https://appuio.ch>`_ (our public OpenShift platform), which allows for an independent description of the necessary pipeline as well as the most relevant concepts for the respective use case.

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
    * Optimizing Gitlab CI configurations using variables and templates
    * ...
* API
    * Dockerizing a Scala Play! application
    * Testing and compiling a Scala Play! application
    * Continuous integration with Gitlab CI
    * Using OpenShift Source2Image for building a docker container
    * Creating a tailor-made Source2Image builder
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

* TODO: will MQ be implemented?
* TODO: will Mailer be implemented?

.. image:: architecture.PNG

A first clear distinction in our application's architecture can be made between the frontend and the backend of the application. The frontend only contains a single service, which is the **Webserver**. The Webserver is basically an instance of nginx that serves some static files (our compiled ReactJS application). 

The backend consists of multiple microservices: a main endpoint (**API**) which will be accessed from the frontend of the application, a service that handles user management and authentication (**Users**), a service that handles order management (**Orders**) and a service responsible for sending emails (**Mailer**). API, Users and Orders each manage their own database to enforce separation of concerns. 

The API connects to other services by using their respective REST endpoints whenever it needs a timely response. If actions may be executed adynchronously, any backend service can communicate with any other by using RabbitMQ (**Message Queue**). The Mailer service doesn't expose an API but instead only listens for new messages from the MQ.


Structure of this documentation
-------------------------------

* TODO: describe structure in more detail?

This documentation is structured such that we first make sure that you know of the most relevant topics and prerequisites for following along later on. The chapter about **General Concepts** provides a short motivation for concepts like Docker and OpenShift and guides you to useful resources if you need to deepen your knowledge about those topics.

The following chapters will each describe one of our services more in depth. We will go into how how a continuous integration pipeline might be built and how the respective service might be packaged for OpenShift, as well as several more advanced topics. We generally try to account for best practices like the `12-Factor App <https://12factor.net>`_.


Where you can find the sources
------------------------------

* TODO: update the sources later on

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