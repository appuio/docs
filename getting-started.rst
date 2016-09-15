Getting Started
===============

Web Console
-----------

Login to the Platform here: `Console <https://console.appuio.ch/>`__

.. _cli-label:

CLI
---

You can download the OpenShift CLI Client (oc) matching the current
OpenShift of APPUiO directly from APPUiO.

- `Windows <https://console.appuio.ch/console/extensions/clients/windows/oc.exe>`__
- `Mac OS X <https://console.appuio.ch/console/extensions/clients/macosx/oc>`__
- `Linux <https://console.appuio.ch/console/extensions/clients/linux/oc>`__

Copy the oc client on your machine into a direcotry on the defined *PATH*

For example: ``~/bin``

Prerequisites
~~~~~~~~~~~~~

For certain commands eg. *oc new-app https://github.com/appuio/example-php-sti-helloworld.git* a locally
installed git client (git command) is required.

Login
~~~~~

``oc login https://console.appuio.ch``

For more information please see `Get Started with the
CLI <https://access.redhat.com/documentation/en/openshift-enterprise/version-3.2/cli-reference/#get-started-with-the-cli>`__

Deploy your first "hello world" example to APPUiO
-------------------------------------------------

See also `Developers: Web Console Walkthrough 
<https://docs.openshift.com/enterprise/latest/getting_started/developers_console.html>`__

PHP Source to Image Hello World Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

check out the `APPUiO PHP Source to image hello World
Example <https://github.com/appuio/example-php-sti-helloworld>`__

PHP Docker Build Hello World Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

check out the `APPUiO PHP Dockerbuild hello World
Example <https://github.com/appuio/example-php-docker-helloworld>`__

Custom Applications
~~~~~~~~~~~~~~~~~~~

check out the `OpenShift Creating New Applications
Docs <https://docs.openshift.com/enterprise/3.2/dev_guide/new_app.html>`__
for other languages, frameworks and strategies

APPUiO - Techlab
----------------
The APPUiO - OpenShift techlab provides a hands on step by step tutorial that allows you to get in touch with the basic concepts. 
Check out our german `APPUiO Techlab <https://github.com/appuio/techlab>`__ .

The german techlab covers:

- Quicktour and basic concepts
- install OpenShift CLI
- First Steps on the Platform (Source To Image deployment from github)
- Deploy a docker image from dockerhub
- Creating routes
- Scaling
- Troubleshooting
- Deploying a database
- Code changes and redeployments
- Attach persistent storage
- how to use application templates

APPUiO Sample Applications
--------------------------
You can find sample applications for APPUiO in our `Application Tutorial section <http://docs.appuio.ch/en/latest/#application-tutorials>`__.

OpenShift Documentation
-----------------------

Please find further documentation here: `OpenShift
docs <https://docs.openshift.com/enterprise/latest/welcome/index.html>`__
