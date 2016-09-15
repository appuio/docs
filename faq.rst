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
a more complex monitoring for your project, feel free to contact us under `support`_.

More information can also be found here:
`Application Health <https://docs.openshift.com/enterprise/latest/dev_guide/application_health.html>`__

What do we backup?
------------------

We backup all data relevant to run the OpenShift cluster. Application
data itself is not in the default backup and is the responsibility of the user.
However we can provide a backup service for individual projects. Please contact us under
`support`_ for more information.

What DNS entries should I add to my custom domain?
--------------------------------------------------

When creating an application route, the platform automatically generates a URL
which is immediately accessible, f.e. ``http://django-psql-example-my-project.appuioapp.ch``
due to wildcard DNS entries under ``*.appuioapp.ch``. If you now want to have this application
available under your own custom domain, follow these steps:

1. Edit the route and change the hostname to your desired hostname, f.e. ``www.myapp.ch``
2. Point your DNS entry using a CNAME resource record type (important!) to ``cname.appuioapp.ch``

Always create a route before pointing a DNS entry to APPUiO, otherwise
someone else could create a matchting route and serve content under your domain.

How can I secure the access to my web application?
--------------------------------------------------

OpenShift supports secure routes and everything is prepared on APPUiO to have
it secured easily. Just edit the route and change the termination type to ``edge``.
There is a default trusted certificate in place for ``*.appuioapp.ch`` which is
used in this case. If you want to use your own certificate, see `Routes <https://docs.openshift.com/enterprise/latest/dev_guide/routes.html>`__.

We're actively working to get support for Let's Encrypt. Coming soon!

.. _support: support@appuio.ch
