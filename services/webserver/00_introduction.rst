Introduction
============

.. note:: This is an early version and still work in progress!

The first part of our microservice architecture that will be explained is the **webserver**. It is the first service the user connects to and one of only two services that are exposed to the user. The webserver consists of an instance of `nginx <https://www.nginx.com>`_ (a high-performance webserver) serving the application's frontend (static files like HTML, CSS, JS and images).

.. image:: webserver_architecture.PNG

The frontend has been designed as a Single-Page-App (SPA) which runs computations in the client's browser and only connects to the API if it needs to fetch data. This is a frequently used pattern in modern web applications as API's often also need to be accessible using native apps and other means. The basic technologies used are `React <https://facebook.github.io/react>`_ (a JavaScript framework), `Webpack <https://webpack.js.org>`_ (a JavaScript bundler) and `Yarn <https://yarnpkg.com>`_ (package management). We won't go into the implementation details, but you are welcome to have a look at the source of the application in the ``docs_webserver`` repository.

The webserver lends itself to some introductory explanations about continuous integration pipelines and docker deployments to APPUiO (building on those in the **General Concepts** section), as the build/deployment pipeline is quite simple and as it doesn't directly depend on any other service. 

What we would like to achieve with our pipeline can be shortly summarized as follows:

#. Run all of the application's tests
#. Build an optimized JavaScript bundle that can be served statically
#. Build a docker container that can be run on APPUiO
#. Push the newly built container directly to the APPUiO registry
#. Trigger a new deployment in APPUiO

The following sections will describe how this pipeline might be implemented using **Gitlab CI**. Topics that will be covered include:

* Building and running the service as a docker container
* Implementing a simple Gitlab CI pipeline with caching and artifacts
* Strategies when using multiple deployment environments (staging, prod etc.)
* Preparing our APPUiO project such that we can deploy the service (routes, deployments etc.)
* Extending our pipeline such that the APPUiO configuration is tracked alongside our source code
* Adding health checks to the deployment of our service
* And others...
