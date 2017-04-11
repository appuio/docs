Orders
======

.. note:: This is an early version and still work in progress!

.. image:: orders_architecture.PNG

.. todo::
    * some more content for the introduction?

The **orders** microservice is a `Python/Flask <http://flask.pocoo.org>`_ application that handles processing of orders and storing them to a PostgreSQL database. As it is a backend service, users won't be able to directly connect to it. The orders microservice will only handle requests from users that have been previously authenticated by the **users** microservice (and as such possess a valid JWT).


Goals for CI
------------

What we would like to achieve with our pipeline can be shortly summarized as follows:

#. Spin up a temporary database and run all of the application’s tests
#. Trigger a source-to-image build on APPUiO
#. Update the application configuration on APPUiO
#. Trigger a new deployment in APPUiO

The following sections will describe how this pipeline might be implemented with **Jenkins**. Topics that will be covered include (among others):

* Creating a docker image for usage as a Jenkins slave
* Using said image for running Jenkins pipelines
* Triggering S2I builds from Jenkins using the OpenShift integration
* Applying the practices learned in the earlier chapters to deploy the service to APPUiO