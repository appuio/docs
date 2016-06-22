How Tos
=======

.. contents::

How to access the OpenShift registry from outside
-------------------------------------------------

To access the internal OpenShift registry from outside, you can use the
following example: ::

  oc login https://master.appuio-beta.ch
  OCTOKEN=$(oc whoami -t)
  docker login -u MYUSERNAME -p $OCTOKEN registry.appuio-beta.ch
  docker pull busybox
  docker tag busybox registry.appuio-beta.ch/MYPROJECT/busybox
  docker push registry.appuio-beta.ch/MYPROJECT/busybox
  oc get imagestreams -n MYPROJECT

How to run scheduled jobs on APPUiO
-----------------------------------

checkout the `APPUiO Cron Job
Example <https://github.com/appuio/example-cron-traditional>`__


