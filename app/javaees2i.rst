Java EE Source to Image
=======================

This example describes how to deploy a Java EE Application to APPUiO using the source to image workflow. It is based on the following example:

* https://github.com/appuio/example-jee-s2i

and uses maven as build tool.


Deployment via oc Client
------------------------

Create new Project if needed: ::

  oc new-project example-jee-s2i

Create app and expose the service, to be able to reach the app from the internet: ::

  oc new-app https://github.com/appuio/example-jee-s2i.git --name=appuio-jee-s2i
  oc expose service appuio-jee-s2i


Deployment via webconsole
-------------------------

#. create new Project
#. Add to Project
#. Choose wildfly
#. enter a name and the repository URL: https://github.com/appuio/example-jee-s2i.git


Configuration
-------------
To overwrite the default standalone configuration you can add your own standalone.xml in the source repository under ::

  ./cfg/


Speed up your build
-------------------

With S2I you can use incremental builds to speed up the build. Build artifacts like maven dependencies will be cached.

set incremental to true in your build config ::

  oc edit bc appuio-jee-s2i


  strategy:
    type: "Source"
    sourceStrategy:
      from:
        kind: "ImageStreamTag"
        name: "appuio-jee-s2i-image:latest"
      incremental: true


