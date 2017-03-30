Introduction
============

.. note:: This is an early version and still work in progress!

The API microservice is one of two services exposed to the end user. It consists of a Scala Play! application which acts as a central endpoint and coordinates the API requests for the entire application.

.. image:: api_architecture.PNG

The service is attached to a PostgreSQL database with product data such that it can directly answer simple queries about products (like index and read). More complicated requests like user authentication or ordering a product are delegated to the corresponding microservice using REST or a message queue. The other microservices send their response to the Play! application, which will then answer the client's original request.


Goals for CI
------------

What we would like to achieve with our pipeline can be shortly summarized as follows:

#. Run all of the application's tests
#. Update the application configuration on APPUiO
#. Trigger an S2I build on APPUiO

The following sections will describe how this pipeline might be implemented using **Gitlab CI**. Topics that will be covered include:

* Building and running the service as a docker container
* Implementing a simple Gitlab CI pipeline with caching and artifacts
* Strategies when using multiple deployment environments (staging, prod etc.)
* Preparing our APPUiO project such that we can deploy the service (routes, deployments etc.)
* Extending our pipeline such that the APPUiO configuration is tracked alongside our source code
* Adding health checks to the deployment of our service
* And others...