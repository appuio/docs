PostgreSQL Backup Image
=======================

Use the Crunchy Data PostgreSQL Backup Container to easily backup your PostgreSQL Databases inside an APPUiO project.

    git clone https://github.com/CrunchyData/crunchy-containers.git
    cd examples/openshift/backup-job/

The backup job requires a persistent volume type such as NFS be mounted by the backup container.
APPUiO provides the Persistent Volume (PV), so the first step to use the backup container is to create a Persistent Volume Claim (PVC).

    oc create -f backup-job-pvc.json


    oc process -f backup-job-nfs.json \
     -v BACKUP_HOST="postgres",BACKUP_USER="userXMS",POSTGRESQL_PASSWORD="XYZ",BACKUP_PORT=5432 \
     | oc create -f -
