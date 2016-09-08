APPUiO Secure Docker Builder
============================

Docker builds from Dockerfiles need access to the Docker Socket and are therefore inherently insecure:
https://docs.docker.com/engine/security/security/#/docker-daemon-attack-surface.
For this reason most multi-tenant container platforms do not support Docker builds.
While OpenShift Container Platform, on which APPUiO is based, improves the security
of builds through the use of SELinux, they are still not secure enough to run
on a multi-tenant platform. Indeed we have we have disabled the
`custom build strategy <https://docs.openshift.com/enterprise/3.2/architecture/core_concepts/builds_and_image_streams.html#custom-build>`__
on APPUiO for this reason.

However, since we regard building Docker images from Dockerfiles
as a vital feature, APPUiO provides its own mechanism called the "APPUiO secure Docker builder" to offer this.
APPUiO secure Docker builder has the following features:

* It is fully compatible with the OpenShift Container Platform Docker builder.
 
Should you observe a difference between the APPUiO Secure Docker builder in behaviour we consider this a bug.
