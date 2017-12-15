FAQ (Technical)
===============

Can I run Containers/Pods as root?
----------------------------------

This is not possible due to security restrictions.

What do we monitor?
-------------------

The functionality of OpenShift and all involved services are completely
monitored and operated by VSHN. Individual projects are not monitored out of
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

Note that you can't use CNAME records in the apex domain (example.com, e.g. without www in front of it). If you need to use the apex domain for your application you have the following options:

1. Redirect to a subdomain (e.g. example.com -> www.example.com or app.example.com) with your DNS-provider, set up the subdomain with a CNAME
2. Use ALIAS-records with your DNS-provider if they support them
3. Enter 5.102.151.2 and 5.102.151.3 as A records

How can I secure the access to my web application?
--------------------------------------------------

OpenShift supports secure routes and everything is prepared on APPUiO to have
it secured easily. Just edit the route and change the termination type to ``edge``.
There is a default trusted certificate in place for ``*.appuioapp.ch`` which is
used in this case. If you want to use your own certificate, see `Routes <https://docs.openshift.com/enterprise/latest/dev_guide/routes.html>`__.

Can I run a database on APPUiO?
-------------------------------

We provide shared persistent storage using GlusterFS. Please make sure that the database intended to use is capable
of storing it's data on a shared filesystem. We don't recommend running production databases with GlusterFS as
storage backend. If you don't fear it, we strongly urge you to at least have a regular database dump available.
On ``https://github.com/appuio?q=backup`` you can find some database dump applications.
For highly-available and high-performance managed databases, please contact the APPUiO team under `hello`_.

.. _support: support@appuio.ch
.. _hello: hello@appuio.ch
