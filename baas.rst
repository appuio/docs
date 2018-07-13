Backup as a Service
===================

.. admonition:: Beta Warning
    :class: note

    This service is currently in beta and seeks for feedback

.. contents::

What is Backup as a Service?
----------------------------

On APPUiO we provide a managed backup service based on `Restic <https://restic.readthedocs.io/>`__.

It's easy as creating a ``backup`` object in the namespace where the data
is which should be in backup. We take care of the rest: Regularly run the
backup job and monitor if and how it is running.

Getting started
---------------

Follow these steps to enable backup in your project:

#. Prepare an S3 endpoint which holds your backup data. We recommend `cloudscale.ch <https://www.cloudscale.ch/>`__
   object storage, but any other S3 endpoint should work.
#. Store the endpoint credentials in a secret: 
   ::

      oc -n mynamespace create secret generic backup-credentials \
        --from-literal=username=myaccesskey \
        --from-literal=password=mysecretaccesskey

#. Store an encryption password in a secret:
   ::

      oc -n mynamespace create secret generic backup-repo \
        --from-literal=password=mybackupencryptionpassword

#. Configure the backup by creating a backup object:
   ::

      oc -n mynamespace apply -f - <<EOF
      apiVersion: appuio.ch/v1alpha1
      kind: Backup
      metadata:
        name: baas-test
      spec:
        schedule: "00 * * * *"
        checkSchedule: "30 0 * * 7" # When the checks should run default once a week
        keepJobs: 4 # How many job objects should be kept to check logs
        backend:
          s3:
            endpoint: https://objects.cloudscale.ch
            bucket: mybackup
        retention: # Default 14 days
          keepLast: 2 # Absolute amount of snapshots to keep overwrites all other settings
          keepDaily: 0
          # Available retention settings:
          # keepLast
          # keepHourly
          # keepDaily
          # keepWeekly
          # keepMonthly
          # keepYearly
      EOF

For figuring out the crontab syntax, we recommend to get help from `crontab.guru <https://crontab.guru/>`__.

.. admonition:: Hintes
    :class: note

    * You can always check the state and configuration of your backup by using ``oc -n mynamespace describe backup``.
    * By default all PVCs are stored in backup. By adding the annotation ``appuio.ch/backup=false`` to a PVC
      object it will get excluded from backup.

Data restore
------------

Restoring data currently has to be done manually from outside the cluster. You need Restic installed.

#. Configure Restic to be able to access the S3 backend:
   ::

      export RESTIC_REPOSITORY=s3:https://objects.cloudscale.ch/mybackup
      export RESTIC_PASSWORD=mybackupencryptionpassword
      export AWS_ACCESS_KEY_ID=myaccesskey
      export AWS_SECRET_ACCESS_KEY=mysecretaccesskey

#. List snapshots:
   ::

      restic snapshots

#. Mount the snapshot:
   ::

      restic mount ~/mnt

#. Copy the data to the volume on the cluster f.e. using the ``oc`` client:
   ::

      oc rsync ~/mnt/hosts/tobru-baas-test/latest/data/pvcname/ podname:/tmp/restore
      oc cp ~/mnt/hosts/tobru-baas-test/latest/data/pvcname/mylostfile.txt podname:/tmp

Please refer to the `Restic documentation <https://restic.readthedocs.io/en/latest/050_restore.html>`__ for
the various restore possibilities.

How it works
------------

A cluster wide Kubernetes Operator is responsible for processing the ``backup`` objects and handle
the backup schedules. When it's time to do a backup, the operator scans the namespace for matching
PVCs and creates a backup job in the corresponding namespace, while mounting the matching PVCs under
``/data/<pvcname>``. Restic then backups the data from this location to the configured endpoint.

Current limitations
-------------------

* Only supports data from PVCs with access mode ``ReadWriteMany`` at the moment
* Backups are not actively monitored / alerted yet

Plans
-----

* Application consistent backup (database dumps, ...)
* Active and automated monitoring by APPUiO staff
* Backup of cluster objects (deployments, configmaps, ...)
* In-Cluster data restore
* Additional backends to S3 by using the rclone backend of Restic
* Open-Sourcing the Operator
