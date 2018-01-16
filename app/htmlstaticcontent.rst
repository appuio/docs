Deploy Static Content to APPUiO
===============================

This example describes how to deploy static content, like html files, images, videos, css, js to APPUiO.

Apache based image
------------------
As base image we are going to use the php:latest OpenShift base image, this image is supported and includes an Apache. In our case it is going to serve the static content.

The following two workflows are supported

Source To image Workflow from Git Repository
````````````````````````````````````````````
the simplest way to deploy static content to APPUiO is by using the `source to image`_ workflow

.. _source to image: https://docs.openshift.com/enterprise/latest/using_images/s2i_images/index.html

The source to image deployment basically scans the git repository and decides based on some rules on how to build the source code located in the respository.
In our case the static content does not need to be built, therefore it simply "copies" the content to the correct location. ::

  /opt/app-root/src

The source to image (S2I) workflow is very powerful, in our example we only use the basic build method. The S2I workflow can easily be extended, by running custom assemble and run scripts. Check out: https://docs.openshift.com/enterprise/latest/creating_images/s2i.html for further information

CLI
^^^

Creating a new App inside a project

**Note:** please check the getting started guide for more information about creating an account, downloading the cli, login and on how to create a new APPUiO project.

::

 oc new-app [builderimage]~[gitrepository]


**RHEL**
::

  oc new-app rhscl/php-56-rhel7~https://github.com/appuio/example-php-sti-helloworld.git

or in case you want to use the **centos** based image:

::

  oc new-app centos/php-56-centos7~https://github.com/appuio/example-php-sti-helloworld.git

**Note:** use ``oc expose service [servicename]``

Webconsole
^^^^^^^^^^

You can also deploy the static content by using the webconsole.

- Navigate to your project overview
- click add to project
- choose base builder image php:latest
- enter git repository url where the static content is located: eg. https://github.com/appuio/example-php-sti-helloworld.git
- click create

the app build is triggered and automatically deployed.


Docker Build Workflow
`````````````````````

The second way to deploy your static content to APPUiO is the docker build. This approach is way more flexible, therefore you have the possibility to either install additional packages inside the image and to customize the build process of your application.

Anyway, in our case we simply add the static content which is located in the app directory in our repository to the docker image:

.. code-block:: docker

  FROM openshift/php-56-centos7
  ADD app /opt/app-root/src
  CMD $STI_SCRIPTS_PATH/run


CLI
^^^

Creating a new app inside a project::

  oc new-app [builderimage] --strategy=docker

for example::

 oc new-app https://github.com/appuio/example-php-docker-helloworld.git --strategy=docker


nginx based image
-----------------

The deployment of your static content inside an nginx based container works similar to the apache based

Source To image
```````````````
You can trigger the deployment with the following command::

  oc new-app centos/nginx-18-centos7~https://github.com/appuio/example-nginx-helloworld.git


Docker Build
````````````
Just change the Base image to the centos nginx image in your Dockerfile

.. code-block:: docker

  FROM centos/nginx-18-centos7
  ADD app /opt/app-root/src
  CMD $STI_SCRIPTS_PATH/run


And create the app on APPUiO, which triggers a build and deployment::

 oc new-app https://github.com/appuio/example-nginx-helloworld.git --strategy=docker


Continuous Integration: Trigger Rebuild
---------------------------------------

If you want code changes to trigger rebuilds and redeployments of your application, you can simply add webhooks.
APPUiO supports generic and github triggers.

check out https://docs.openshift.com/enterprise/latest/dev_guide/builds.html#webhook-triggers for further information.






