How Tos
=======

.. contents::

How to access the OpenShift registry from outside
-------------------------------------------------

To access the internal OpenShift registry from outside, you can use the
following example: ::

  oc login https://console.appuio.ch
  OCTOKEN=$(oc whoami -t)
  docker login -u MYUSERNAME -p $OCTOKEN registry.appuio.ch
  docker pull busybox
  docker tag busybox registry.appuio.ch/MYPROJECT/busybox
  docker push registry.appuio.ch/MYPROJECT/busybox
  oc get imagestreams -n MYPROJECT

How to run scheduled jobs on APPUiO
-----------------------------------

checkout the `APPUiO Cron Job
Example <https://github.com/appuio/example-cron-traditional>`__


How to access an internal service while developing
-------------

E.g. accessing a hosted PostgreSQL on port 5432 while developing locally.

To access a service (a single pod, to be more specific) from your local machine, make sure you have installed the OpenShift CLI (as described in the `official documentation <https://docs.openshift.com/online/cli_reference/get_started_cli.html>`__).

Login to the OpenShift CLI ::

  user@local:~$ oc login

Get a list of your currently running pods ::

  user@local:~$ oc get pods
  NAME                         READY     STATUS      RESTARTS   AGE
  play-postgres-1-9ste1        1/1       Running     0          9s

With the name of the pod running your service, run the ``oc port-forward`` command, also specifying the **port** you would like to access ::

  user@local:~$ oc port-forward play-postgres-1-9ste1 5432
  Forwarding from 127.0.0.1:5432 -> 5432
  Forwarding from [::1]:5432 -> 5432

Your service may now be accessed via ``localhost:port``. For more advanced usage of ``oc port-forward`` consider the `official documentation <https://docs.openshift.com/container-platform/3.4/dev_guide/port_forwarding.html>`__.

