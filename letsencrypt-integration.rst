Let's Encrypt Integration
=========================

`Let's Encrypt`_ is a certificate authority that provides free SSL/TLS
certificates via an automated process.  Their certificates are accepted by
most of today's browsers.

APPUiO provides integration with Let's Encrypt to automatically create, sign,
install and renew certificates for your domains running on APPUiO.

To create a certificate for one of your domains follow these steps:

#. If you haven't already done so create a route for the fully qualified domain
   name (FQDN), e.g. ``www.example.org``, your application should run under. If
   using the web console, make sure you do *not* tick the "Secure Route" box
   when creating the route.
#. Add a CNAME record (important!) for the FQDN to the DNS of your domain
   pointing to ``cname.appuioapp.ch``.
   E.g. in BIND: ``www  IN  CNAME  cname.appuioapp.ch.`` (the trailing dot
   is required)
#. Annotate your route:

   .. code-block:: console

      oc -n MYNAMESPACE annotate route ROUTE kubernetes.io/tls-acme=true

.. warning::

   Always **create a route** `before` **pointing a DNS entry** to APPUiO and
   always **remove the corresponding DNS entry** `before` **deleting a route**
   for a domain of yours.  Otherwise someone else could potentially create a
   route and a Let's Encrypt certificate for your domain.

.. note::

   #. APPUiO automatically renews certificates a few days before they expire.
   #. Let's Encrypt can only create `domain validated certificates`_,
      i.e. it's not possible to add an organization name to a Let's Encrypt
      certificate.

.. warning::

   The certificate renewal fails if the DNS entry is not pointing to APPUiO.
   Therefore we will remove the ``kubernetes.io/tls-acme=true`` annotation
   if the certificate is up for renewal and the DNS entry is not pointing to APPUiO
   for more than 7 days.

   If the DNS entry is corrected you can re-add the annotation to get a new certificate.


You only need the annotation on one Route if you use multiple Routes with same hostname, but different paths.
For example, only the Route with hostname ``www.example.org`` and path ``/`` needs the annotation.
The Route with same hostname ``www.example.org`` but path ``/subpath`` does not.
Be sure to still enable TLS with termination type ``edge`` on the subpath Route, but leave the certificate fields empty.

If you don't specify a ``host`` value in your `Route object`_ APPUiO will use
its default domain ``appuioapp.ch`` for your convenience to create a working
subdomain for your application.

Creating certificates for this domain is neither needed nor supported as APPUiO
already has a wildcard certificate installed for ``*.appuioapp.ch``.  Without
this wildcard certificate we would hit the `Let's Encrypt rate limits`_ on the
``appuioapp.ch`` domain sooner or later.

Implementation details
----------------------

APPUiO uses the `OpenShift ACME controller`_ to provide the Let's Encrypt
integration.

The certificates are stored in the target Route object in the corresponding
project.  If you require the certificate to be stored as a Secret, to mount it
into your Pod for SSL Passthrough, add the ``acme.openshift.io/secret-name``
annotation, e.g.

.. code-block:: console

   oc -n MYNAMESPACE annotate route ROUTE acme.openshift.io/secret-name=MYSECRETNAME


.. _Let's Encrypt: https://letsencrypt.org/
.. _Let's Encrypt rate limits: https://letsencrypt.org/docs/rate-limits/
.. _domain validated certificates: https://en.wikipedia.org/wiki/Domain-validated_certificate
.. _Route object: https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html#route-hostnames
.. _OpenShift ACME controller: https://github.com/tnozicka/openshift-acme
