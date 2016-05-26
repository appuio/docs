Node Maintenance
================

All details are documented under `Managing Nodes <https://docs.openshift.com/enterprise/latest/admin_guide/manage_nodes.html>`__.

Prepare for maintenance
-----------------------

To get a node into maintenance mode: ::

  oadm manage-node <node> --schedulable=false
  oadm manage-node <node> --evacuate

To get a node out of maintenance mode: ::

  oadm manage-node <node> --schedulable
