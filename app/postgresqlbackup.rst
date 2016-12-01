PostgreSQL Backup Image (the manual way)
========================================

Use the Crunchy Data PostgreSQL Backup Container to easily backup your PostgreSQL Databases inside an APPUiO project: ::

  git clone https://github.com/CrunchyData/crunchy-containers.git
  cd examples/openshift/backup-job/

The backup job requires a persistent volume type such as NFS be mounted by the backup container. APPUiO provides the Persistent Volume (PV), so the first step to use the backup container is to create a Persistent Volume Claim (PVC). ::

  oc create -f backup-job-pvc.json

First we need a admin user on the PostgreSQL database to be able to do a WAL backup. Therefore you should edit the deployment config of the database container and add the following env variable: ::

 name: POSTGRESQL_ADMIN_PASSWORD 
 value: yourPassword

Create the backup job and container: ::

  oc process -f backup-job-nfs.json \
    -v CCP_IMAGE_TAG="1.2.1"\
DATABASE_HOST="postgres",DATABASE_USER="postgres",\
DATABASE_PASS="yourPassword",DATABASE_PORT=5432 \
    | oc create -f -

Note, that the BACKUP_PASS value has to be the same password as configured in the postgres deployment description.
