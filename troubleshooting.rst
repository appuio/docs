Troubleshooting
===============

If your app does not deploy or run have a look at some tips here. If you don't find your error or do find an error message you don't understand come to the community chat at https://community.appuio.ch and ask.

The tips are structured in three categories: how to inspect the build process, how to inspect the deploy process, how to inspect your running application and some specific tipps and error messages at the end of each part.


Build
-----

Note that the build process of your application is just another pod that you can look at in the Web-GUI or CLI. The build process will use computing resources in your quota just like your application does, if there are no more available resources the build won't run.


How to get build logs in the Web-GUI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While the build is running there is a "view log" link in the overview, you can find all the logs of all the builds in the Menu under Builds -> Builds and select the build config of your application from the list.
All the previous builds are listed, the newest with the highest build number is at the top. You can click the build number to get more information about what triggered the build and inspect the build logs under the "Logs"-Tab


How to get build logs in the CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``oc logs buildconfig/yourappname`` for the latest or ``oc logs buildconfig/yourappname --previous`` for the penultimate build. You can abbreviate the command to ``oc logs bc/yourappname``. To stream the logs in real-time during the build you can append the ``-f`` parameter: ``oc logs -f bc/yourappname``.

To access the build log history you get the log of the builder pod:

1. get the list of past builder pods with ``oc get pods``. You want the pod to have a name like yourappname-123-build where 123 is the build number.
2. get the logs with ``oc logs yourappname-123-build``


Build Error: manifest blob unknown: blob unknown to registry
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Problem: The Openshift project app and base image have the same name causing Openshift to use the same ImageStreamTag for source and destination. ::

  Pushed 13/13 layers, 100% complete
  Registry server Address:
  Registry server User Name: serviceaccount
  Registry server Email: serviceaccount@example.org
  Registry server Password: <<non-empty>>
  error: build error: Failed to push image: errors:
  manifest blob unknown: blob unknown to registry
  manifest blob unknown: blob unknown to registry
  manifest blob unknown: blob unknown to registry
  manifest blob unknown: blob unknown to registry

Solution: Use a different app name: ``oc new-app --name``.

Since ``oc`` version 1.5/3.5 the ``new-app`` command throws an error if there is a conflict.


Build Error: Error pushing to registry: Authentication is required
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Due to a known race condition when instantiating a template (https://github.com/openshift/origin/issues/4518) the first build can fail at pushing the resulting container. Just re-start the build process from the Web-GUI or through the CLI with ``oc new-build yourappname``.


Deployment
----------

How to get deployment logs in the Web-GUI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While a deployment is running you'll see the status in the overview. You can see all the build events in the Menu under Applications -> Deployments and select the name of the deployment in the list you want to inspect. The history of the deployment will be shown below the configuration, when you click on the deployment number you can inspect the deployment events in the "Events"-Tab.

To see all Events you can click on Monitoring in the Menu, then in the top-right there are "Events" and then "View Details".


How to get deployment logs in the CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You get all the cluster events with ``oc get events``.


Deployment error: Error creating: pods "yourappname-123-" is forbidden: exceeded quota: compute-resources, requested: limits.cpu=500m, used: limits.cpu=1600m, limited: limits.cpu=2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The deployment failed because the quota was enforced. In this example the CPU-quota was reached as 500mCPU was requested while 1600mCPU was already used, the limit being 2000mCPU (2000 millicores-CPU = 2 CPU).

You can change how much CPU/RAM your application requests on the deployment settings page: Menu Applications -> Deployments, choose your deployment and then "Actions" on the top-right and "Edit Resource Limits". The default is 100mCPU requested, 500mCPU hard limit, 100MB RAM requested and 512MB RAM hard limit. You can tune this down depending on your application e.g. to 50mCPU requested, 100mCPU limit, 50MB RAM requested, 100MB RAM limit.

When changing the resource limits a new deployment is started automatically to apply the new settings. If you were so close to your resource limit that the rolling deployment can't start the new container before the old is gone you can either change the deployment strategy from "rolling" to "replace" or (e.g. if you want downtime-less deployments and are usually within quota):

1. cancel the deployment (e.g. from the overview page)

   .. image:: troubleshooting-limit.png

2. manually scale the app to 0 pods

   .. image:: troubleshooting-scale.png

3. restart the deployment (e.g. from the overview page or from Applications->Deployments->yourappname->Deploy)

   .. image:: troubleshooting-restart.png

4. manually scale the app back to 1 pod

   .. image:: troubleshooting-scaleup.png

You can change your global quota limit by upgrading your APPUiO.ch-package.

Deployment Error: Error syncing pod, skipping: timeout expired waiting for volumes to attach/mount
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This error means there was a problem with attaching the requested persistent volume, which can be due to:

1. no more storage available -> please contact support
2. there needs to be a "glusterfs-cluster" service in your project. The service is created automatically when your account is set up but that can be deleted by the user. If you don't have this service and you start using persistent volumes please contact support or create the service yourself: ::

    oc create -f - <<EOF
    apiVersion: v1
    items:
    - apiVersion: v1
      kind: Service
      metadata:
        creationTimestamp: null
        name: glusterfs-cluster
      spec:
        ports:
        - port: 1
          protocol: TCP
          targetPort: 1
        sessionAffinity: None
        type: ClusterIP
      status:
        loadBalancer: {}
    - apiVersion: v1
      kind: Endpoints
      metadata:
        creationTimestamp: null
        name: glusterfs-cluster
      subsets:
      - addresses:
        - ip: 172.17.176.30
        - ip: 172.17.176.31
        - ip: 172.17.176.32
        ports:
        - port: 1
          protocol: TCP
    kind: List
    metadata: {}
    EOF


Application Logs
----------------

How to get application logs in the Web-GUI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Click in the Menu under Applications -> Pods and choose your application pod, named ``yourappname-123-a1b2c3``. In the "Logs"-Tab you can see the application log output. To follow the newest lines click "Follow" in the top-right corner of the dark log window.


How to get application logs in the CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can access the application log output from the current deployment with ``oc logs dc/yourappname``. You can live-stream the log with the ``-f`` parameter: ``oc logs -f dc/yourappname``.

To access the application log of a specific pod:

1. get the list of pods with ``oc get pods``. You want the pod to have a name like yourappname-123-a1b2c3 where 123 is the build number and the last part is random.
2. get the log with ``oc logs yourappname-123-a1b2c3`` or live-streamed with ``oc logs -f yourappname-123-a1b2c3``

