Running the container
=====================

In order to run our app, we will need to build the JavaScript sources with Webpack and then inject the bundle into a docker container (using docker build). The easiest way to try this without having to install all the necessary dependencies is to use our provided Vagrant box. 

After starting the box and connecting with ``vagrant ssh``, we can run the following commands:

**Testing the application**: ``yarn install`` and ``yarn test``

**Building the sources**: ``yarn run build`` (after ``yarn install``)

**Building a container**: ``docker build . -t docs_webserver:latest``

**Running the container**: ``docker run -it docs_webserver:latest --name webserver``

You should now have a working frontend which you can reach using ``VAGRANT_VM_IP:9000``.

In the next section, we will implement all of those steps as an automated pipeline using Gitlab CI.

**Relevant Readings / Resources**

#. TBD
