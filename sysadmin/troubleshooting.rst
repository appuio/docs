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

  etcdctl -C https://master1.beta.puzzle.cust.vshn.net:2379,\
    https://master2.beta.puzzle.cust.vshn.net:2379,\
    https://master3.beta.puzzle.cust.vshn.net:2379 \
    --ca-file=/etc/origin/master/master.etcd-ca.crt \
    --cert-file=/etc/origin/master/master.etcd-client.crt \
    --key-file=/etc/origin/master/master.etcd-client.key cluster-health

Issues and their solutions
--------------------------

Issue:
  In a multi-master setup the service ``atomic-openshift-master-api`` starts successfully but startup takes longer than usual and it logs the following errors:
  ::

    ensure.go:237] waiting for policy cache to initialize
    ensure.go:237] waiting for policy cache to initialize
    ensure.go:237] waiting for policy cache to initialize
    ...
    ensure.go:243] error waiting for policy cache to initialize: timed out waiting for the condition
    ensure.go:256] Could not auto reconcile roles: User "system:anonymous" cannot get clusterroles at the cluster scope
    ensure.go:269] Could not auto reconcile role bindings: User "system:anonymous" cannot get clusterrolebindings at the cluster scope
    ensure.go:206] Unable to create default security context constraint privileged.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:206] Unable to create default security context constraint nonroot.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:206] Unable to create default security context constraint hostmount-anyuid.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:206] Unable to create default security context constraint hostaccess.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:206] Unable to create default security context constraint restricted.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:206] Unable to create default security context constraint anyuid.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:206] Unable to create default security context constraint hostnetwork.  Got error: User "system:anonymous" cannot create securitycontextconstraints at the cluster scope
    ensure.go:107] Error adding service account roles to "default" namespace: User "system:anonymous" cannot get namespaces in project "default"
    ensure.go:54] Error creating namespace openshift-infra: User "system:anonymous" cannot create namespaces at the cluster scope

Solution:
   The master needs to synchronize its cluster policy cache with other masters. In order to do so it needs a valid configuration
   to login to other masters with the ``system:openshift-master`` account in ``/etc/origin/master/openshift-master.kubeconfig``.

....
  
Issue:
  Docker 1.10 fails to create containers with the following error messages:
  ::
  
    oci-register-machine[5676]: 2016/07/28 15:55:28 Register machine: prestart 6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249 5672 /var/lib/docker/devicemapper/mnt/2b4bcf3683c61dc8b9884459cceb6e1e8150d6d9d432118e2703cda66aeea3ac/rootfs
    forward-journal[4796]: time="2016-07-28T15:55:28.279749573+02:00" level=warning msg="exit status 2"
    forward-journal[4796]: time="2016-07-28T15:55:28.438219006+02:00" level=error msg="error locating sandbox id 5c13a081bb7f2143e67ef863f4125a3b85f9d15710a09484ac62a1f17ded3a88: sandbox 5c13a081bb7f2143e67ef863f4125a3b85f9d15710a09484ac62a1f17ded3a88 not found"
    forward-journal[4796]: time="2016-07-28T15:55:28.438304065+02:00" level=warning msg="failed to cleanup ipc mounts:\nfailed to umount /var/lib/docker/containers/6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249/shm: invalid argument"
    forward-journal[4796]: time="2016-07-28T15:55:28.438333805+02:00" level=error msg="Error unmounting container 6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249: not mounted"
    forward-journal[4796]: time="2016-07-28T15:55:28.438624705+02:00" level=error msg="Handler for POST /containers/6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249/start returned error: cantstart: Cannot start container 6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249: [9] System error: exit status 127"
    forward-journal[4796]: time="2016-07-28T15:55:28.438666200+02:00" level=error msg="Handler for POST /containers/6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249/start returned error: Cannot start container 6c5cd75f3295435df5705defe3ffa40e3e6e6624880df4776a2527e42c710249: [9] System error: exit status 127"

Solution:
  The package ``yajl`` (Yet Another JSON Library), a dependency of ``oci-systemd-hook`` which is in turn a dependency of ``docker``, has not been installed because another package provides ``libyajl.so.2`` in another location, e.g. ``icinga2-bin``. Workaround: ``yum install yayl`` on all Docker hosts.

