Backup as a Service
===================

.. admonition:: Beta Warning
    :class: note

    This service is currently in beta and seeks for feedback

.. contents::

What is Backup as a Service?
----------------------------

On APPUiO we provide a managed backup service based on `Restic <https://restic.readthedocs.io/>`__.

Just create a ``backup`` object in the namespace you'd like to backup.
It's that easy. We take care of the rest: Regularly run the backup job and
monitor if and how it is running.

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
      apiVersion: backup.appuio.ch/v1alpha1
      kind: Schedule
      metadata:
        name: schedule-test
      spec:
        backend:
          repoPasswordSecretRef:
            name: backup-repo
            key: password
          s3:
            endpoint: http://10.144.1.224:9000
            bucket: baas
            accessKeyIDSecretRef:
              name: backup-credentials
              key: username
            secretAccessKeySecretRef:
              name: backup-credentials
              key: password
        backup:
          schedule: ' 0 1 * * *'
          keepJobs: 10
          promURL: http://10.144.1.224:9000
        check:
          schedule: ' 0 0 * * 0'
          promURL: http://10.144.1.224:9000
        prune:
          schedule: ' 0 4 * * *'
          retention:
            keepLast: 5
            keepDaily: 14
      EOF

For figuring out the crontab syntax, we recommend to get help from `crontab.guru <https://crontab.guru/>`__.

.. admonition:: Hints
    :class: note

    * You can always check the state and configuration of your backup by using ``oc -n mynamespace describe schedule``.
    * By default all PVCs are stored in backup. By adding the annotation ``appuio.ch/backup=false`` to a PVC
      object it will get excluded from backup.

Application aware backups
*************************
It's possible to define annotations on pods with backup commands. These backup commands should create an application aware
backup and stream it to stdout.

Define an annotation on pod:

::

      <SNIP>
      template:
        metadata:
          labels:
            app: mariadb
          annotations:
            appuio.ch/backupcommand: mysqldump -uroot -psecure --all-databases
      <SNIP>

With this annotation the operator will trigger that command inside the the container and capture the stdout to a backup.

Tested with:
* MariaDB
* MongoDB

But it should work with any command that has the ability to output the backup to stdout.

Data restore
------------
There are two ways to restore your data once you need it.

Automatic restore
*****************

This kind of restore is managed via CRDs. These CRDs support two targets for restores:

* S3 as tar.gz
* To a new PVC (mostly untested though → permissions might need some more investigation)

Example of a restore to S3 CRD:

::

      apiVersion: backup.appuio.ch/v1alpha1
      kind: Restore
      metadata:
        name: restore-test
      spec:
        restoreMethod:
          s3:
            endpoint: http://10.144.1.224:9000
            bucket: restoremini
            accessKeyIDSecretRef:
              name: backup-credentials
              key: username
            secretAccessKeySecretRef:
              name: backup-credentials
              key: password
        backend:
          s3:
            endpoint: http://10.144.1.224:9000
            bucket: baas
            accessKeyIDSecretRef:
              name: backup-credentials
              key: username
            secretAccessKeySecretRef:
              name: backup-credentials
              key: password
            repoPasswordSecretRef:
              name: backup-repo
              key: password

The S3 target is intended as some sort of self service download for a specific backup state. The PVC restore is intended as a form of disaster recovery. Future use could also include automated complete disaster recoveries to other namespaces/clusters as way to verify the backups.

Manual restore
**************
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

* Active and automated monitoring by APPUiO staff
* Backup of cluster objects (deployments, configmaps, ...)
* In-Cluster data restore
* Additional backends to S3 by using the rclone backend of Restic
* Open-Sourcing the Operator
