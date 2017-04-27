Integrating Jenkins with APPUiO
==============================

.. note:: This is an early version and still work in progress!

.. todo::
    * describe how the jenkins openshift integrations works (dynamically created slaves etc)
    * describe how to get openshift to start an instance of jenkins? (auto-provisioning?)
    * describe that a fitting image needs to be created for those slaves
    * describe creation of said image 
    * describe how to add the slave image as a normal docker build
    * describe how to configure jenkins such that it uses the slave imag

Recent developments on the OpenShift platform have introduced a growing number of possibilities for integration with the Jenkins CI/CD platform. An instance of Jenkins that runs on OpenShift can now easily access deployments and builds.

For example, triggering a new build on OpenShift can be done with a simple command without any complicated login procedures. Also, the status of Jenkins pipelines can be displayed directly inside the OpenShift web interface (when deployments are appropriately configured).

However, even though Jenkins on OpenShift offers easy integration, there are some caveats when running jobs. To achieve the same kind of flexibility we had in Gitlab CI (using custom runners etc.), we need to build so called Jenkins "slaves". These slaves are docker images that are based on the official slave base image (`jenkins-slave-base-centos7 <https://hub.docker.com/r/openshift/jenkins-slave-base-centos7>`_) and extend it by the packages and dependencies that will be needed within the jobs. 

Once prepared and configured, the slave images are started as pods when a new job starts and are removed after a defined time or after the job finishes. For the orders service, this slave image will only need to contain Python, as dependencies will be installed within the job.