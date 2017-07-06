Spring Boot Application in Wildfly
==================================

This example shows how to deploy a Spring Boot application with Wildfly to APPUiO. See the source code and Readme at:

* https://github.com/appuio/springdemo

We use the Maven-based source-to-image (s2i) build process for Wildfly applications.

TL;DR: see https://github.com/appuio/springdemo for how to run it

Spring Boot Application
-----------------------

For this exercise I created a new and empty Spring Boot application at https://start.spring.io/ with the Web and Actuator modules, specifying "war" as the packaging format for Wildfly.

The empty application produces an error message when accessed at / because there is nothing there to handle the request. I added a minimal Controller Class (SpringdemoController) that outputs "Hello!" when accessed at / to have something to test with later.

OpenShift Build Process
-----------------------

As-is the application can be built using the Wildfly source-to-image (s2i) builder, but it would be accessible under the resulting build artifact name in the URL: /springdemo-0.0.1-SNAPSHOT/ which I don't like. I thus changed the build artifact name (<finalName>) in the maven configuration pom.xml to ROOT which tells Wildfly to expose it at /.

With these additions you can create a new app from this code: ::
  oc new-app openshift/wildfly:latest~https://github.com/appuio/springdemo.git
  oc expose service springdemo

OpenShift Template
------------------

In the previous step we needed to manually expose the "springdemo" service to create an externally accessible route/URL for it. Also, we couldn't specify any healthcheck URLs either, so there must be a better way: OpenShift Templates: ::
  oc new-app -f https://raw.githubusercontent.com/appuio/springdemo/master/springdemo-template.json

The template includes both the building and running instructions and makes it easier to instantiate multiple copies of the same application stack. It could (but does not in this example) contain multiple services that needed to be grouped together (e.g. application and databases).

You can set parameters when instantiating a template: ::
  oc new-app -f https://raw.githubusercontent.com/appuio/springdemo/master/springdemo-template.json # default appname=springdemo
  oc new-app -f https://raw.githubusercontent.com/appuio/springdemo/master/springdemo-template.json -p APPNAME=second
  oc new-app -f https://raw.githubusercontent.com/appuio/springdemo/master/springdemo-template.json -p APPNAME=third

You can see all available parameters on the CLI with: ::
  oc process -f https://raw.githubusercontent.com/appuio/springdemo/master/springdemo-template.json --parameters

The resulting applications have labels with the appname associated with them, so to delete them again you can: ::
  oc delete all -l appname=springdemo
  oc delete all -l appname=second
  oc delete all -l appname=third

Or to delete all instances of the template: ::
  oc delete all -l template=springdemo

For more information about templates: see https://docs.openshift.com/container-platform/latest/dev_guide/templates.html

