Non HTTP Services / TCP Ingress
===============================

Accessing a TCP or UDP service without using the provided
OpenShift router via the ``route`` object is possible via a
Load Balancer type service.

To use it just create a service with the type ``LoadBalancer``. Example:

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: myapp
    spec:
      ports:
      - name: mytcpapp
        port: 5000
      type: LoadBalancer
      selector:
        app: myapp

The cluster automatically assigns a unique external IPv4 address to this
service. To see which IPv4 address has been assigned, go to the webconsole and
navigate to "Applications -> Services". The IP is displayed in the field
"External IP". Using the CLI is also possible: ``oc describe svc myapp``.

.. note::
    * Only IPv4 is supported, IPv6 is not available for this service yet
    * Additional costs will apply for each external IP

.. admonition:: Relevant Readings / Resources
    :class: note

    :openshift:`Using a Load Balancer to Get Traffic into the Cluster [OpenShift Docs] <dev_guide/expose_service/expose_internal_ip_load_balancer.html>`
