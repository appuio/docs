PHP 7 with Apache Source to Image Example
-----------------------------------------

This is a PHP 7 Apache Source to image example based on the following s2i Builder

https://github.com/getupcloud/sti-php.git

**Note**: at the moment no official php 7 sti image is available: https://github.com/sclorg/s2i-php-container

Build Builder
~~~~~~~~~~~~~

To use the builder we need to build it first, since it is not yet available as official builder

Create new Project and create app::

  oc new-project php7example


Create Builder with oc client: ::

  oc new-app https://github.com/getupcloud/sti-php.git --strategy=docker --context-dir='7.0' --name="php7-apache-s2i"
  oc delete svc php7-apache-s2i
  oc delete dc php7-apache-s2i

Create Builder by template, and build builder: ::

  oc new-app -f https://raw.githubusercontent.com/appuio/example-php-sti-helloworld/master/template/php7apaches2ibuilder-template.json

You have to wait until the builder is ready

Deploy App
~~~~~~~~~~

Build, deploy and create the PHP s2i App: ::

  oc new-app php7-apache-s2i~https://github.com/appuio/example-php-sti-helloworld.git


