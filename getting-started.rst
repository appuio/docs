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

- `Windows <https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-windows.zip>`__
- `macOS <https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-mac.zip>`__
- `Linux <https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz>`__

Copy the oc client on your machine into a direcotry on the defined *PATH*

For example: ``~/bin``

The latest OpenShift 3.11 CLI is not compatible with macOS Monterey (12). Available workarounds are:
- Using the latest OpenShift CLI (4.x) from https://github.com/openshift/okd/releases/ (some incompatibilites with 3.11 used on APPUiO)
- Running the OpenShift CLI through Docker with the image `docker.io/appuio/oc:v3.11`

Prerequisites
~~~~~~~~~~~~~

For certain commands eg. *oc new-app https://github.com/appuio/example-php-sti-helloworld.git* a locally
installed git client (git command) is required.

Login
~~~~~

``oc login https://console.appuio.ch``

For more information please see :openshift:`Get Started with the CLI <cli_reference/get_started_cli.html>`.

APPUiO Sample Applications
--------------------------
If you want to deploy your first "hello world" example, see OpenShift's :openshift:`Developers: Web Console Walkthrough <getting_started/developers_console.html>`. Or dive right into some sample applications for APPUiO in our `Application Tutorial section </en/latest/#app-tutorials>`__.

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

OpenShift Documentation
-----------------------

Please find further documentation here: `OpenShift
docs <https://docs.openshift.com/enterprise/latest/welcome/index.html>`__
