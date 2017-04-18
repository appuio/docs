Troubleshooting
===============

Read Logs
---------

Pods
~~~~

To access Pod logs, there are several ways:

-  Running Pod: ``oc logs <podname>`` or via Web Console
-  Not running Pod (f.e. failed): ``oc logs --previous <podname>``

Builds
~~~~~~

To see build logs, use:

-  ``oc logs bc/<name>``
-  ``oc logs -f bc/<name>``

Start a new build:

-  ``oc start-build <name>``

oc logs
~~~~~~~

``oc logs --help`` gives several examples and help for reading log files

Common Errors
-------------

Build fails after successful push
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Problem: The Openshift project app and base image have the same name causing Openshift to use the same ImageStreamTag for source and destination.
```
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
```
Solution: Use a different app name: `oc new-app --name`. Since `oc` version 1.5/3.5 the `new-app` command throws an error if there is a conflict.
