Docker Image
============

This example shows how to deploy a pre built docker image to APPUiO. At the moment APPUiO only works with Docker schema 1 Docker Images.

Create new Project if needed: ::

  oc new-project dockerimage

Deploy Image from Dockerhub and expose the service, to be able to reach the app from the internet: ::

  oc new-app appuio/example-spring-boot --name=appuio-spring-boot-ex
  oc expose service appuio-spring-boot-ex

APPUiO downloads the Docker image with the given name and deploys the image.

Please consider the image creation Guide: https://docs.openshift.com/enterprise/3.2/creating_images/guidelines.html

Check out our Techlab for further infos https://github.com/appuio/techlab/blob/lab-3.2/labs/04_deploy_dockerimage.md
