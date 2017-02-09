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
--------------------------------------------------

E.g. accessing a hosted PostgreSQL on port 5432 while developing locally.

To access a service (a single pod, to be more specific) from your local machine, make sure you have installed the OpenShift CLI (as described in the `official documentation <https://docs.openshift.org/latest/cli_reference/get_started_cli.html>`__).

Login to the OpenShift CLI:

::

  $ oc login

Get a list of your currently running pods:

::

  $ oc get pods
  NAME                         READY     STATUS      RESTARTS   AGE
  play-postgres-1-9ste1        1/1       Running     0          9s

With the name of the pod running your service, run the ``oc port-forward`` command, also specifying the **port** you would like to access:

::

  $ oc port-forward play-postgres-1-9ste1 5432
  Forwarding from 127.0.0.1:5432 -> 5432
  Forwarding from [::1]:5432 -> 5432

Your service may now be accessed via ``localhost:port``. For more advanced usage of ``oc port-forward`` consider the `official documentation <https://docs.openshift.org/latest/dev_guide/port_forwarding.html>`__.


How to use a private repository (on e.g. Github) to run S2I builds
------------------------------------------------------------------

1. Create an SSH keypair
^^^^^^^^^^^^^^^^^^^^^
Create an SSH keypair **without passphrase**:

::

  $ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
  Generating public/private rsa key pair.
  Enter file in which to save the key: id_rsa
  Enter passphrase (empty for no passphrase): 
  Enter same passphrase again: 
  Your identification has been saved in id_rsa.
  Your public key has been saved in id_rsa.pub.

The private key has been saved as ``id_rsa``, the public key as ``id_rsa.pub``. You will need both of them, store them in a secure location.

2. Create a deploy key
^^^^^^^^^^^^^^^^^^^

To allow the newly generated key to pull your repository, you have to specify the public key as a deploy key for your project.

GitHub
""""""
TBD

Gitlab
""""""
TBD

For OpenShift to be able to access a private repository, the Gitlab instance needs to be configured for SSH access.

3. Save the private key in an OpenShift secret
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Add a new ssh secret to your OpenShift project, specyfing the path of your ssh private key:

::

  $ oc secrets new-sshauth sshsecret --ssh-privatekey=id_rsa
  secret/sshsecret

A new secret called ``sshsecret`` has been added. In order to allow OpenShift to pull your repository, the newly saved secret also has to be linked to the builder service account:

::

  $ oc secrets link builder sshsecret

A more detailed explanation of this step can be found in the `official documentation <https://docs.openshift.org/latest/dev_guide/builds.html#ssh-key-authentication>`__.

4. Create a new build config in OpenShift
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now that OpenShift knows your private key and the builder is able to use it, you can create a new S2I build configuration, specifying your private repository as a source.

Create a new build config using the following command:

::

  $ oc new-build YOUR_REPOSITORY_SSH_URL --strategy="source"

Add the ``sshsecret`` to the newly created build config:

::

  $ oc set build-secret --source bc/newly-created-build sshsecret

All of those steps are also explained in the `official documentation <https://docs.openshift.org/latest/dev_guide/builds.html#ssh-key-authentication>`__.