MSSQL Server on APPUiO
=======================

This example shows how to deploy the mssql linux docker image to APPUiO. *For demo purposes only and we use the evaluation version.*

Quick Summary
-------------

The basic deployment and configuration of a mssql database container is done by the following commands

::

  oc new-app microsoft/mssql-server-linux --name=mssql-server-linux
  oc env dc mssql-server-linux -e ACCEPT_EULA=Y -e SA_PASSWORD=somerandom.Pa55word
  oc volume dc/mssql-server-linux --add --name=mssql-data --mount-path=/var/opt/mssql

In Detail
---------

Deploy the mssql docker container
::

  oc new-app microsoft/mssql-server-linux --name=mssql-server-linux


Configuration
~~~~~~~~~~~~~

To run this image you need to read and accept the `End-User License Agreement <http://go.microsoft.com/fwlink/?LinkID=746388>`__ and if accepted set the environment variable ``ACCEPT_EULA`` to ``Y``

You also need to define a secure SA password
::

  oc env dc mssql-server-linux -e ACCEPT_EULA=Y -e SA_PASSWORD=somerandom.Pa55word


You might want to adjust the resource limits

Persistent Storage
~~~~~~~~~~~~~~~~~~

You should also add a persistent volume and mount under ``/var/opt/mssql``

**Empty Dir for Test only**
::

  oc volume dc/mssql-server-linux --add --name=mssql-data --mount-path=/var/opt/mssql


**Persistent Storage**
::

  oc volume dc/mssql-server-linux --add --name=mssql-data --type persistentVolumeClaim \
     --claim-name=mssql-data --claim-size=256Mi --mount-path=/var/opt/mssql


Create Database
~~~~~~~~~~~~~~~

To connect to the database directly from your system you must create a port forward into the container ``oc port-forward [POD] 1433:1433``

Create a new database connection in your desired client (eg. squirelsql) using user sa and the given password.
Execute the following commands to create the database
::

  create database databasename;
  GO
  use databasename;
  CREATE LOGIN dbuser WITH PASSWORD = 'dbuserPW', CHECK_POLICY = OFF;
  CREATE USER [dbuser] FROM LOGIN [dbuser];
  exec sp_addrolemember 'db_owner', 'databasename';
  GO


Delete MSSQL 
~~~~~~~~~~~~
::

  oc delete all -l app=mssql-server-linux -n [yourproject]

