Persistant Storage
==================

Resize Gluster Volumes
-------------

The following commands must be executed on every node. To find out which volume is bound to the pod run:

  * `oc get pv`

Resize the underlying logical volume:

  * `lvextend /dev/vg_gluster/gluster_vol_16 -L+1G`

The filesystem is now smaller than the volume and must be resized. For xfs use the former command otherwise the latter:

  * `xfs_growfs /dev/vg_gluster/gluster_vol_16`
  * `resize2fs /dev/vg_gluster/gluster_vol_16`

Edit the storage capacity inside the persistant volume:

  * `oc edit pv gluster-pv16`

The persistant volume claim will still show the old size.
