Building and running the container
=================================

.. note:: This is an early version and still work in progress!

For our API microservice, using source-to-image meant that we had to build a custom S2I-builder image, which is quite a bit of work. Python is much simpler in this regard, as we can simply leverage one of the predefined S2I-builders that come with OpenShift (provided by the CentOS project). 

All of the builders the CentOS project provides can be found on `Docker Hub <https://hub.docker.com/r/centos>`_. For this specific use case, we will be using the `python-35-centos7 builder <https://hub.docker.com/r/centos/python-35-centos7>`_, which is obviously based on CentOS 7 and Python 3.5. Some of the other builders that are available are PHP 7.0, Ruby 2.3, NodeJS 4 and many more.

To build our application with Python 3.5, we can then simply run this command:

``s2i build --incremental=true . centos/python-35-centos7 shop-example-orders``

This will build a runnable version of the container from the sources in the current directory. The Python application needs to be specifically configured such that it runs with S2I. For example, one has to define

