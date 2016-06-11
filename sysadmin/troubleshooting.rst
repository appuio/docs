OpenShift Cluster Troubleshooting
=================================

Resources in OpenShift documentation
------------------------------------

  * `OpenShift Network Access, includes required ports <https://docs.openshift.com/enterprise/3.2/install_config/install/prerequisites.html#prereq-network-access>`_
  * `Troubleshooting OpenShift SDN <https://docs.openshift.com/enterprise/3.2/admin_guide/sdn_troubleshooting.html>`_

Multi-master etcd
-----------------

Report cluster health: 

.. code:: bash

  etcdctl -C https://master1.beta.puzzle.cust.vshn.net:2379,https://master2.beta.puzzle.cust.vshn.net:2379,https://master3.beta.puzzle.cust.vshn.net:2379 
  --ca-file=/etc/origin/master/master.etcd-ca.crt --cert-file=/etc/origin/master/master.etcd-client.crt --key-file=/etc/origin/master/master.etcd-client.key cluster-health
