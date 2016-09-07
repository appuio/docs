FAQ (Technical)
===============

Can I run Containers/Pods as root?
----------------------------------

This is not possible due to security restrictions. For more information, see
`Root Access to Docker Images <https://forum.appuio.ch/topic/7/root-access-to-docker-images>`__

What do we monitor?
-------------------

The functionality of OpenShift and all involved services are completely
monitored and operated by VSHN. Individual projects are not monitored our of
the box - but Kubernetes already has health checks integrated and running. Also
replication controllers make sure that Pods are running all the time. If you need
a more complex monitoring for your project, feel free to contact us under `<mailto:support@appuio.ch>`__.

More information can also be found here:
`Application Health <https://docs.openshift.com/enterprise/latest/dev_guide/application_health.html>`__

What do we backup?
------------------

We backup all data relevant to run the OpenShift cluster. Application
data itself is not in the default backup and is the responsibility of the user.
However we can provide a backup service for individual projects. Please contact us under
`<mailto:support@appuio.ch>`__ for more information.

