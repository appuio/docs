Monitoring
==========

Read-only System Account
------------------------

For monitoring cluster resources it's important to have a read-only
system account. ::

  echo "{\"kind\":\"ServiceAccount\",\"apiVersion\":\"v1\",\"metadata\":{\"name\":\"monitoring\"}}" | oc create -n default -f -
  oadm policy add-cluster-role-to-user view system:serviceaccount:default:monitoring
  oc get secrets | grep monitoring
  oc describe secret monitoring-token-XXXXX

The token can be used to login with ``oc login --token=TOKEN``
