Non HTTP Services / TCP Ingress
===============================

To access services which are using another protocol than HTTP a
TCP ingress service is available.

Just create a service with the type Load Balancer. Example:

.. code-block:: yaml
    :linenos:

    apiVersion: v1
    kind: Service
    metadata:
      creationTimestamp: null
      labels:
        app: myapp
      name: myapp
    spec:
      ports:
      - name: 1883-1883
        port: 1883
        protocol: TCP
        targetPort: 1883
      selector:
        app: myapp
      type: LoadBalancer

The cluster automatically assigns a unique external IPv4 address to this
service. It can be seen by going to the webconsole under Applications ->
Services: "External IP" or by using the CLI `oc describe svc myapp`.

Learn more about this service type in the official OpenShift
documentation under
`Using a Load Balancer to Get Traffic into the Cluster <https://docs.openshift.com/container-platform/3.6/dev_guide/expose_service/expose_internal_ip_load_balancer.html>`__

Please note:
* Only IPv4 is supported, IPv6 is not yet available for this service
* Additional costs will apply for each external IP
