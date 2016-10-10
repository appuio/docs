Node JS 6 Example
=================

This example describes how to deploy a Node.js to APPUiO. It is based on the following app:

Easy file upload / download server: https://github.com/topaxi/tmpy

How to deploy to APPUiO / OpenShift Cluster
-------------------------------------------

Create a new project ::

  oc new-project tmpy


Create app, since tmpy uses Node 6 as runetime, and node 6 is not yet available in the current scl source-to-image images (https://github.com/sclorg/s2i-nodejs-container) we use the origin version available under https://github.com/openshift-s2i/s2i-nodejs-community ::

  oc new-app ryanj/centos7-s2i-nodejs:6.3.1~https://github.com/topaxi/tmpy.git


OpenShift Container Platform Version less than 3.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you want to deploy your tmpy to OpenShift Container Platform Version less than 3.3 you will encounter an Docker Schema version issue.

Switch  sourceStrategy ImageStreamTag(centos7-s2i-nodejs:6.3.1) to DockerImage (ryanj/centos7-s2i-nodejs:6.3.1)::

  oc edit bc tmpy


Database
--------

tmpy uses a mongo DB to store the state ::

  oc new-app mongodb-ephemeral -pDATABASE_SERVICE_NAME=mongodb -pMONGODB_USER=tmpy -pMONGODB_PASSWORD=tmpy -pMONGODB_DATABASE=tmpy


Configuration
-------------

You now need to configure your App via ENV
add the following configuration to your deploymentConfig ::

  oc env dc tmpy -e TMPY_PORT=8080 -e TMPY_IP=0.0.0.0 -e TMPY_DB_HOST=mongodb -e TMPY_DB_NAME=tmpy -e TMPY_DB_USER=tmpy -e TMPY_DB_PASSWORD=tmpy -e TMPY_HOSTNAME=tmpy.appuio.ch

