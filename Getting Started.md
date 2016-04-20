# Beta Platform

Login to the Beta Platform

## CLI

### Installing the CLI

#### Download
You can download the OpenShift CLI Client (oc) matching the current OpenShift of APPUiO directly from APPUiO.

* [Windows](https://master.appuio-beta.ch/console/extensions/clients/windows/oc.exe)
* [Mac OS X](https://master.appuio-beta.ch/console/extensions/clients/macosx/oc)
* [Linux](https://master.appuio-beta.ch/console/extensions/clients/linux/oc)
 
Copy the oc client on your machine into a direcotry on the defined *PATH*

For example: ~/bin

#### Brewing (Mac OS X)
The OpenShift CLI Client can be installed using  [brew](http://brew.sh/).

```bash
brew install openshift-cli
```
 
#### Prerequisites

For certain commands eg. *oc new-app https://github.com/appuio/example-php-sti-helloworld.git* a locally installed git client (git command) is required. 


### Basic Setup and Login

`oc login https://master.appuio-beta.ch`

For more information please see [Get Started with the CLI](https://access.redhat.com/documentation/en/openshift-enterprise/version-3.1/cli-reference/#get-started-with-the-cli)

## Web Console

[Master Console](https://master.appuio-beta.ch/console/)

# How to deploy your first "hello world example to APPUiO?

## PHP Source to Image Hello World Example

check out the [APPUiO PHP Source to image hello World Example](https://github.com/appuio/example-php-sti-helloworld)

## PHP Docker Build Hello World Example

check out the [APPUiO PHP Dockerbuild hello World Example](https://github.com/appuio/example-php-docker-helloworld)

## Custom Applications 

check out the [OpenShift Creating New Applications Docs](https://docs.openshift.com/enterprise/3.1/dev_guide/new_app.html) for other languages, frameworks and strategies

# Documentation

* Further [OpenShift docs](https://docs.openshift.com/enterprise/3.1/welcome/index.html)
