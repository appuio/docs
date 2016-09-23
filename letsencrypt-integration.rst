Let's Encrypt Integration
=========================

Let's Encrypt is a certificate authority that provides free SSL/TLS certificates via an automated process.
Let's Encrypt certificates are accepted by most of todays browsers. 
APPUiO provides integration with Let's Encrypt to automatically create, sign, install and renew certificates for your Domains running on APPUiO.

To create a certificate for one of your domains follow these steps:

#. If you don't already have done so create a route for the fully qualified domain name your application should run under
#. Add a DNS entry for your domain to APPUiO
#. Visit ``letsencrypt.appuio.ch/yourdomain`` to create and install the certificate

Creating certificates for the default domain ``appuioapp.ch`` is neighter needed nor supported as APPUiO already has a
wildcard certificate installed for ``*.appuioapp.ch``.
