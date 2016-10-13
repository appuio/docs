PHP 7 with Nginx Source to Image Example
----------------------------------------

This is a PHP 7 Nginx Source to image example based on the following s2i Builder

https://github.com/codecasts/s2i-nginx-php7-container


Build Builder
~~~~~~~~~~~~~

To use the builder we need to build it first, since it is not yet available as official builder

Create new Project and create app::

  oc new-project php7example


  oc new-app https://github.com/codecasts/s2i-nginx-php7-container.git --strategy=docker --context-dir='7.0'

  oc delete dc s2i-nginx-php7-container
  oc delete svc s2i-nginx-php7-container


oc new-app s2i-nginx-php7-container~https://github.com/appuio/example-php-sti-helloworld.git


