Let's Encrypt Integration
=========================

Let's Encrypt is a certificate authority that provides free SSL/TLS certificates via an automated process.
Let's Encrypt certificates are accepted by most of todays browsers. 
APPUiO provides integration with Let's Encrypt to automatically create, sign, install and renew certificates for your domains running on APPUiO.

To create a certificate for one of your domains follow these steps:

#. If you haven't already done so create a route for the fully qualified domain name (FQDN), e.g. ``www.example.org``, your application should run under
#. Add a CNAME record (important!) for the FQDN to the DNS of your domain pointing to ``cname.appuioapp.ch``. E.g. in BIND: ``www  IN  CNAME  cname.appuioapp.ch.`` (the trailing dot is required)
#. Visit ``https://letsencrypt.appuio.ch/<mydomain.tld>`` to create and install the certificate, e.g. ``https://letsencrypt.appuio.ch/www.example.org``. Login with your APPUiO account.

Creating certificates for the default domain ``appuioapp.ch`` is neither needed nor supported as APPUiO already has a
wildcard certificate installed for ``*.appuioapp.ch``. Without this wildcard certificate we would hit the `Let's Encrypt rate limits <https://letsencrypt.org/docs/rate-limits/>`__ on the ``appuioapp.ch`` domain sooner or later.

**Important:** Always create a route before pointing a DNS entry to APPUiO and always remove the corresponding DNS entry before deleting a route for a domain of yours. Otherwise someone else could potentially create a route and a Let's Encrypt certificate for your domain.

Please note:

#. APPUiO automatically renews certificates created through https://letsencrypt.appuio.ch/ 30 days before they expire
#. We are working to improve the user experience of the Let's Encrypt integration
#. If you have more than one route for one hostname (FQDN) configured, i.e. path based routes, the certificate is currently only installed into one route. This will be resolved with the improved user experience.
#. Let's encrypt can only create `domain validated certificates <https://en.wikipedia.org/wiki/Domain-validated_certificate>`__, i.e. it's not possible to add an organization name to a Let's Encrypt certificate.
