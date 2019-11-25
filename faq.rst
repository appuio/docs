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


Route monitoring
~~~~~~~~~~~~~~~~

Certificates on application routes are monitored for validity. Users or cluster
operators may set any of the following annotations on routes:

* ``monitoring.appuio.ch/enable``: Whether to monitor route at all (boolean,
  default ``true``)
* ``monitoring.appuio.ch/enable-after``: Whether to monitor route after
  specified point in time (time, no default).
* ``monitoring.appuio.ch/verify-tls-certificate``: Whether to verify X.509
  certificate validity (boolean as string, default ``true``).
* ``monitoring.appuio.ch/not-after-remaining-warn``,
  ``monitoring.appuio.ch/not-after-remaining-crit``:
  Amount of time before reporting warning or critical status when the primary
  route certificate is to expire (duration).

Value formats:

* Boolean: ``"false"`` or ``"true"``.
* Time: Supported formats (see
  `time.ParseInLocation <https://golang.org/pkg/time/#ParseInLocation>`__):

    * 2006-01-02T15:04:05Z07:00
    * 2006-01-02T15:04Z07:00
    * 2006-01-02T15:04
    * 2006-01-02

* Duration: Parsed using Go's
  `time.ParseDuration <https://golang.org/pkg/time/#ParseDuration>`__ function,
  e.g. ``168h30m``.


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


Which IP addresses are being used?
----------------------------------

**Disclaimer**: These addresses may change at any time. We do not recommend
whitelisting by IP address. A better option is to use `Transport
Layer Security (TLS) <https://en.wikipedia.org/wiki/Transport_Layer_Security>`__
with client certificates for authentication.

Incoming connections for routes
  ``5.102.151.2``,
  ``5.102.151.3``

Outgoing connections from pods
  ``5.102.147.130``,
  ``5.102.147.124``,
  ``2a06:c00:10:bc00::/56``


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

If you still want to run a database on GlusterFS, please inform us about your deployment, so that we can apply some
tunings on the volumes. Otherwise there is a risk of data corruption and when that happens, your database will not 
run/start anymore.

I get an error like 'Failed Mount: MountVolume.NewMounter initialization failed for volume "gluster-pv123" : endpoints "glusterfs-cluster" not found'
-----------------------------------------------------------------------------------------------------------------------------------------------------

When you received your account there was a service called "glusterfs-cluster" pointing to the persistent storage endpoint. If you delete it by accident you can re-create it with::

  oc create -f - <<EOF
  apiVersion: template.openshift.io/v1
  kind: List
  items:
  - apiVersion: v1
    kind: Service
    metadata:
      name: glusterfs-cluster
    spec:
      ports:
      - port: 1
        protocol: TCP
        targetPort: 1
  - apiVersion: v1
    kind: Endpoints
    metadata:
      name: glusterfs-cluster
    subsets:
    - addresses:
      - ip: 172.17.176.30
      - ip: 172.17.176.31
      - ip: 172.17.176.32
      ports:
      - port: 1
        protocol: TCP
  EOF

Or copy the YAML between "oc" and "EOF" in the Web-GUI to "Add to project" -> "Import YAML/JSON"
Or run ``oc create -f https://raw.githubusercontent.com/appuio/docs/master/glusterfs-cluster.yaml``

Please note that the IP addresses above are dependent on which cluster you are on, these are valid for console.appuio.ch


How do I kill a pod/container
-----------------------------

If your container is hanging, either because your application is unresponsive or because the pod is in state "Terminating" for a long time, you can manually kill the pod::

   oc delete pod/mypod

If it still hangs you can use more force::

   oc delete --grace-period=0 --force pod/mypod

The same functionality is available in the Web-GUI: Applications -> Pods -> Actions -> Delete, there is a checkbox "Delete pod immediately without waiting for the processes to terminate gracefully" for applying more force

How do I work with a volume if my application crashes because of the data in the volume?
----------------------------------------------------------------------------------------

If your application is unhappy with the data in a persistent volume you can connect to the application pod::

  oc rsh mypod

to run commands inside the application container, e.g. to fix or delete the data. In the Web-GUI this is Applications -> Pods -> mypod -> Terminal.

If your application crashes at startup this does not work as there is no container to connect to - the container exits as soon as your application exits. If there is a shell included in your container image you can use `oc debug` to clone your deployment config including volumes for a one-off debugging container::

  oc debug deploymentconfig/prometheus

If your container image does not include a shell or you need special recovery tools you can start another container image, mount the volume with the data and then use the tools in the other container image to fix the data manually. Unfortunately the `oc run` command does not support specifying a volume, so we have to create a deployment config with the volume for it to be mounted and make sure our deployed container does not exit:

1. get the name of the persistent volume claim (pvc) that contains the data. In this example the application and deployment config (dc) name is 'prometheus'
::

  oc volume dc/prometheus

This produces the following output::

  deploymentconfigs/prometheus
    configMap/prometheus-config as prometheus-config-1
      mounted at /etc/prometheus
    pvc/prometheus-data (allocated 1GiB) as prometheus-volume-1
      mounted at /prometheus

you can see the pvc/prometheus-data is the persistent volume claim that is mounted at "/prometheus" for the application prometheus.

2. Deploy the helper container (e.g. "busybox", minimal container containing a shell) - if you need special tools to fix the data (e.g. to recover a database) you should use another container image containing these tools), patch it not to exit and mount the volume at /mnt
::

  # create a new deployment with a "busybox" shell container
  oc new-app busybox
  # patch the new deployment with a while-true-loop so the container keeps on running
  oc patch dc/busybox -p '{"spec":{"template":{"spec":{"containers":[{"name":"busybox","command":["sh"],"args":["-c","while [ 1 ]; do echo hello; sleep 1; done"]}]}}}}'
  # mount the persistent volume claim into the container at /mnt
  oc volume dc/busybox --add -m /mnt -t pvc --claim-name prometheus-data
  # wait for the new deployment with the mount to roll out

.. warning::
   The `oc patch` command above has a problem with escaping on windows cmd/powershell. You can add the "command" and "args" keys and values in the Web-GUI.

3. connect to your helper container and work in the volume
::

  oc rsh dc/busybox
  cd /mnt/
  # congratulations, you are now in the volume you want to fix
  # you can now selectively delete/edit/clean the bad data

4. clean up the temporary deployment config afterwards
::

  oc delete all -l app=busybox

How long do we keep application logs?
-------------------------------------

Application logs are stored in elasticsearch and accessible via Kibana.
All container logs are sent there but only kept for 10 days.

Is OpenShift Service Catalog available to be used?
--------------------------------------------------

OpenShift Service Catalog is not supported nor available to be used on APPUiO.
Template Service Broker and OpenShift Ansible Broker are not supported nor available.
It was once available, but because Red Hat is `removing the support of the Service Catalog from OpenShift <https://docs.openshift.com/container-platform/4.1/release_notes/ocp-4-1-release-notes.html#ocp-41-deprecated-features>`__, we decided to remove the Service Catalog from APPUiO.
