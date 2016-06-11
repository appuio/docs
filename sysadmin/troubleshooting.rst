OpenShift Cluster Troubleshooting
=================================

Multi-master etcd
-----------------

Report cluster health: 

.. code:: bash

  etcdctl -C https://master1.beta.puzzle.cust.vshn.net:2379,https://master2.beta.puzzle.cust.vshn.net:2379,https://master3.beta.puzzle.cust.vshn.net:2379 
  --ca-file=/etc/origin/master/master.etcd-ca.crt --cert-file=/etc/origin/master/master.etcd-client.crt --key-file=/etc/origin/master/master.etcd-client.key cluster-health
