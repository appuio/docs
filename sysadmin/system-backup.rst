Backup of Cluster Components
============================

etcd
----

The following command creates a dump: ::

  ETCD_DIR=/var/lib/etcd
  ETCD_BAK=${ETCD_DIR}.bak
  etcdctl backup --data-dir $ETCD_DIR --backup-dir $ETCD_BAK

To restore the data, follow this steps: `Restoring etcd <https://docs.openshift.com/enterprise/latest/install_config/downgrade.html#downgrading-restoring-etcd>`__
