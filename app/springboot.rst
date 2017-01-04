Spring Boot Application
=======================

This example describes how to deploy a Spring Boot Application to APPUiO. It is based on the following example:

* https://github.com/appuio/example-spring-boot-helloworld

which is based on the docker build workflow and builds the java artifact during docker build step with gradle. The same concept applies if you want to use maven as your build too.


Dockerfile
-----------

During Docker build the following steps are executed

#. install Java
#. build Spring Boot Application
#. deploy to correct location

Dockerfile: ::

    FROM openshift/base-centos7

    ...

    EXPOSE 8080

    ...

    # Install Java
    RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
        yum install -y $INSTALL_PKGS && \
        rpm -V $INSTALL_PKGS && \
        yum clean all -y && \
        mkdir -p /opt/s2i/destination

    USER 1001

    # add application source

    ADD ./gradlew /opt/app-root/src/
    ADD gradle /opt/app-root/src/gradle
    ADD build.gradle /opt/app-root/src/
    ADD src /opt/app-root/src/src

    # build
    RUN sh /opt/app-root/src/gradlew build
    # copy to correct location
    RUN cp -a  /opt/app-root/src/build/libs/springboots2idemo*.jar /opt/app-root/springboots2idemo.jar

    CMD java -Xmx64m -Xss1024k -jar /opt/app-root/springboots2idemo.jar



Deployment
----------

Create new Project if needed: ::

  oc new-project example-spring-boot

Create app and expose the service, to be able to reach the app from the internet: ::

  oc new-app https://github.com/appuio/example-spring-boot-helloworld.git --strategy=docker --name=appuio-spring-boot-ex
  oc expose service appuio-spring-boot-ex

Add ephemeral mysql Database, this step is optional, by default Spring Boot uses a ephemeral internal H2 Database: ::

  oc new-app mysql-ephemeral -pMYSQL_USER=appuio -pMYSQL_PASSWORD=appuio -pMYSQL_DATABASE=appuio -pDATABASE_SERVICE_NAME=mysql

**Warning:** do use ephemeral databases only for testing purposes, use databases with persistent volumes attached for production environments

Configuration
-------------
basically Spring Boot Applications can be configured out of the box by setting environment variables. This means there is no wrapping mechanism needed to be able to set configuration values in your Spring Application.
http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html

The only thing you have to do is to set the environment variables in the given Deployment Config.

For example set the connection parameters for our database connection: ::

  oc env dc appuio-spring-boot-ex -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql/appuio?autoReconnect=true \
  -e SPRING_DATASOURCE_USERNAME=appuio -e SPRING_DATASOURCE_PASSWORD=appuio \
  -e SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.jdbc.Driver



