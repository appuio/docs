Building and running the container
=================================

For our API microservice, using source-to-image meant that we had to build a custom S2I-builder image, which is quite a bit of work. Python is much simpler in this regard, as we can simply leverage one of the predefined S2I-builders that come with OpenShift (provided by the CentOS project). 

All of the builders the CentOS project provides can be found on `Docker Hub <https://hub.docker.com/r/centos>`_. For this specific use case, we will be using the `python-35-centos7 builder <https://hub.docker.com/r/centos/python-35-centos7>`_, which is obviously based on CentOS 7 and Python 3.5. Some of the other builders that are available are PHP 7.0, Ruby 2.3 and NodeJS 4.

To build a runnable container for application (based on Python 3.5), we can simply run this command:

.. code-block:: bash
    
    $ s2i build --incremental=true . centos/python-35-centos7 shop-example-orders

After this build completes, the service can be run using the ``docker-compose.yml`` file we have prepared. This ensures that the orders service gets valid configuration passed and that the associated database is started as well.

The Python application needs to be specifically configured such that it runs with this S2I-Builder (as can be found on the Docker Hub page). For example, one has to define the needed Python packages inside a pip ``requirements.txt`` file that the S2I assemble script can then use to install these dependencies.

Additionally, a file called ``.s2i/environment`` defines which environment variables should be set inside the container (much like ENV in a Dockerfile). For the orders service, this file specifies the name of the Python entrypoint as well as the name of the Gunicorn config file.

That's basically all there is to building the Python application with S2I. This shows that interpreted languages like Python and PHP are most definitely the cases where the Source-To-Image paradigm performs best (in terms of complexity as well as ease of use) and can be seen as an improvement over traditional Dockerfile based deployments.
