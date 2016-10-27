Spring Boot Application with Angular 2 Frontend
===============================================

This example describes how to deploy a Spring Boot Application to APPUiO. It is based on the following example:

* https://github.com/KeeTraxx/springboot-workshop

which is based on the docker build workflow and builds the java artifact during docker build step with gradle. The same concept applies if you want to use maven as your build too.


Dockerfile
-----------

During Docker build the following steps are executed

#. install Java
#. build Spring Boot Application

Dockerfile: ::

    FROM openshift/base-centos7

    EXPOSE 8080

    # Install Java
    RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
        yum install -y $INSTALL_PKGS && \
        rpm -V $INSTALL_PKGS && \
        yum clean all -y && \
        mkdir -p /opt/s2i/destination

    USER 1001

    # add application source

    ADD . /opt/app-root/src

    # build
    RUN sh /opt/app-root/src/gradlew build

    CMD java -Xmx64m -Xss1024k -jar /opt/app-root/src/build/libs/*.jar



Deployment
----------

Create new Project if needed: ::

  oc new-project spring-boot-angular

Create app and expose the service, to be able to reach the app from the internet: ::

  oc new-app https://github.com/KeeTraxx/springboot-workshop.git --strategy=docker --name=spring-boot-angular-ex
  oc expose service spring-boot-angular-ex


Configuration
-------------
Basically Spring Boot Applications can be configured out of the box by setting environment variables. This means there is no wrapping mechanism needed to be able to set configuration values in your Spring Application.
http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html

The only thing you have to do is to set the environment variables in the given deployment config.

For example set the connection parameters for our database connection: ::

  oc env dc spring-boot-angular-ex -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql/appuio?autoReconnect=true \
  -e SPRING_DATASOURCE_USERNAME=appuio -e SPRING_DATASOURCE_PASSWORD=appuio \
  -e SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.jdbc.Driver



