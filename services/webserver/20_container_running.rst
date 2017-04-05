Running the container
=====================

.. note:: This is an early version and still work in progress!

In order to run our app, we will need to build the JavaScript sources with Webpack and then inject the bundle into a docker container (using docker build). The easiest way to try this without having to install all the necessary dependencies is to use our provided Vagrant box. 

After starting the box and connecting with ``vagrant ssh``, we can run the following commands:

**Testing the application**: ``yarn install`` and ``yarn test``

After the tests have successfully finished, we can create an application bundle:

**Building the sources**: ``yarn run build`` (after ``yarn install``)

As soon as a bundle has been created, we can build a docker container and inject said bundle:

**Building a container**: ``docker build . -t shop-example-webserver``

The newly created container can then be run as follows:

**Running the container**: ``docker run -it shop-example-webserver --name webserver``

You should now have a working frontend which you can reach using ``VAGRANT_VM_IP:9000``.

In the next section, we will implement all of those steps as an automated pipeline using Gitlab CI.
