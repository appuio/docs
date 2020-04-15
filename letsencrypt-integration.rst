Let's Encrypt Integration
=========================

`Let's Encrypt <https://letsencrypt.org/>`__ is a certificate authority that 
provides free SSL/TLS certificates via an automated process.
Their certificates are accepted by most of todays browsers.

APPUiO provides integration with Let's Encrypt to automatically create, sign, 
install and renew certificates for your domains running on APPUiO.

To create a certificate for one of your domains follow these steps:

#. If you haven't already done so create a route for the fully qualified domain 
   name (FQDN), e.g. ``www.example.org``, your application should run under
#. Add a CNAME record (important!) for the FQDN to the DNS of your domain
   pointing to ``cname.appuioapp.ch``. 
   E.g. in BIND: ``www  IN  CNAME  cname.appuioapp.ch.`` (the trailing dot 
   is required)
#. Annotate your route:
   ``oc -n MYNAMESPACE annotate route ROUTE kubernetes.io/tls-acme=true``

Creating certificates for the default domain ``appuioapp.ch`` is neither needed
nor supported as APPUiO already has a wildcard certificate installed for
``*.appuioapp.ch``.
Without this wildcard certificate we would hit the
`Let's Encrypt rate limits <https://letsencrypt.org/docs/rate-limits/>`__ on the
``appuioapp.ch`` domain sooner or later.

**Important:** Always create a route before pointing a DNS entry to APPUiO and
always remove the corresponding DNS entry before deleting a route for a domain
of yours.
Otherwise someone else could potentially create a route and a Let's Encrypt
certificate for your domain.

Please note:

#. APPUiO automatically renews certificates a few days before they expire
#. Let's encrypt can only create
   `domain validated certificates <https://en.wikipedia.org/wiki/Domain-validated_certificate>`__,
   i.e. it's not possible to add an organization name to a Let's Encrypt
   certificate.

Implementation details
----------------------

APPUiO uses the `OpenShift ACME controller <https://github.com/tnozicka/openshift-acme>`__
to provide the Let's Encrypt integration. 

The certificates are stored in the target Route object in the corresponding
project. If you require the certificate to be stored as a Secret as well, add the 
``acme.openshift.io/secret-name`` annotation, e.g.
``oc -n MYNAMESPACE annotate route ROUTE acme.openshift.io/secret-name=mysecretname``
