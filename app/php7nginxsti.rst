PHP 7 with Nginx Source to Image Example
----------------------------------------

This is a PHP 7 Nginx Source to image example based on the following s2i Builder

https://github.com/appuio/s2i-nginx-php7-container.git

**Note**: at the moment no official php 7 sti image is available: https://github.com/sclorg/s2i-php-container

Please consider this example as tech preview

Build Builder
~~~~~~~~~~~~~

To use the builder we need to build it first, since it is not yet available as official builder

Create new Project and create app::

  oc new-project php7example


Create Builder with oc client: ::

  oc new-app https://github.com/appuio/s2i-nginx-php7-container.git --strategy=docker --context-dir='7.0' --name="php7-nginx-s2i"
  oc delete svc php7-nginx-s2i
  oc delete dc php7-nginx-s2i

Create Builder by template, and build builder: ::

  oc new-app -f https://raw.githubusercontent.com/appuio/example-php-sti-helloworld/master/template/php7nginxs2ibuilder-template.json

You have to wait until the builder is ready

Deploy App
~~~~~~~~~~

Build, deploy and create the PHP s2i App: ::

  oc new-app php7-nginx-s2i~https://github.com/appuio/example-php-sti-helloworld.git


