Implementing a CI Pipeline
==========================

.. image:: orders_pipeline.PNG

Contrary to the pipelines we have built so far, the CI pipeline for the *orders* service will be built with Jenkins (instead of Gitlab CI). We chose this approach to be able to showcase several continuous integration toolchains instead of focusing on just a single system.

The pipeline we are going to create in this chapter structurally looks a lot like the previous ones. However, the semantic representation of pipelines between Gitlab CI and Jenkins is different. This chapter will thus focus on these differences and build up the pipeline for our service step-by-step.

Scripted vs. Declarative Pipeline
---------------------------------

Similar to the way Gitlab CI defines its pipeline in a ``gitlab-ci.yml`` file, a Jenkins pipeline is defined in a so called ``Jenkinsfile``. There are two different ways of structuring a Jenkinsfile: as a **Scripted Pipeline** or as a **Declarative Pipeline**.

A scripted pipeline is basically *Groovy* code that can use Jenkins specific commands and is then serially executed to run the pipeline. Scripted pipelines are very flexible in that they are basically only restricted by the capabilities of the Groovy language. However, this means that one needs to be able to code Groovy to create a more complex pipeline.

The declarative pipeline syntax has been introduced only recently to provide a syntax that can be read and written by people without the necessity to know Groovy. Many parts of its structure are predefined, which makes it less flexible but more expressive. Additionally, its more opinionated syntax already enforces some best practices. There are ways to use snippets of scripted pipeline inside a declarative pipeline, such that some of the benefits of both can be combined.

As Gitlab CI uses a YAML syntax which in itself is also declarative, we will structure the Jenkinsfile for the orders service as a declarative pipeline. However, there will be some snippets of scripted pipeline included, as the restrictions of the declarative pipeline would not allow some of our specific use cases.

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `Syntax Comparison [Jenkins Docs] <https://jenkins.io/doc/book/pipeline/syntax/#compare>`_


Basic structure of a declarative pipeline
-----------------------------------------

To explain the concepts we applied while building the pipeline for this service, we will build up step by step from the very simple pipeline that can be seen below:

.. code-block:: groovy
    :caption: Jenkinsfile
    :linenos:
    :emphasize-lines: 2-6, 9-14

    pipeline {
      agent {
        // run with the custom python slave
        // will dynamically provision a new pod on APPUiO
        label 'python'
      }

      stages {
        stage('test') {
          // TODO
          steps {
            echo 'hello world'
          }
        }

        stage('deploy-staging') {
          steps {
            // TODO
          }
        }

        stage('deploy-preprod') {
          steps {
            // TODO
          }
        }

        stage('deploy-prod') {
          steps {
            // TODO
          }
        }
      }
    }

This (working) pipeline shows the basic conventions that we need to use while building up our pipeline. The entire pipeline needs to be wrapped in a ``pipeline`` block. This block contains a list of named ``stages``, which are defined using the ``stage(name)`` function. A ``steps`` block inside each stage then contains the commands that will be executed in that particular stage.

The ``agent`` block on lines 2-6 specifies the executor that our pipeline should use for the stages. In our case, we want Jenkins to use our custom Jenkins slave, which is why we define ``label 'python'``. We defined this label when configuring the Jenkins pod template in the previous chapter. One thing to note is that the agent directive can be specified on a pipeline level as seen above and/or on a stage level (which you will see later on).

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `Pipeline Syntax [Jenkins Docs] <https://jenkins.io/doc/book/pipeline/syntax>`_
    #. `Pipeline Examples [Github] <https://github.com/jenkinsci/pipeline-examples>`_
    #. `Pipeline Best Practices [Github] <https://github.com/jenkinsci/pipeline-examples/blob/master/docs/BEST_PRACTICES.md>`_


Implementing the test stage
---------------------------

As usual, the first thing we want to do in our pipeline will be testing the application. The tests for the orders application depend on the existence of a database, which means that Jenkins will need to dynamically spin up a database on APPUiO each time the pipeline is run.

The way we implemented this for the orders service can be shortly summarized as follows:

    #. Create a DeploymentConfig for an ephemeral instance of postgres
    #. Set the number of replicas for this instance to zero
    #. On each run of the Jenkins pipeline:
        #. Scale the deployment to one replica
        #. Install pip packages that are needed for testing
        #. Perform the tests
        #. Scale the deployment to zero replicas (even if tests fail!)

.. note:: As the database is ephemeral, no data will be persisted and therefore each round of testing will be based on an empty database. Other implementations might need to reset/purge the database before each round of testing.


Creating an ephemeral database
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create an ephemeral instance of PostgreSQL, we can use the ``postgresql-ephemeral`` template from the OpenShift catalog. The following command will instantiate the template using the CLI:

.. code-block:: bash

    $ oc new-app postgresql-ephemeral -p DATABASE_SERVICE_NAME=orders-test,POSTGRESQL_USER=orders,POSTGRESQL_PASSWORD=secret,POSTGRESQL_DATABASE=orders --name orders-test
    --> Deploying template "postgresql-ephemeral" in project "openshift"

        PostgreSQL (Ephemeral)
        ---------

        ...

    --> Creating resources with label app=postgresql-ephemeral ...
        secret "orders-test" created
        service "orders-test" created
        deploymentconfig "orders-test" created
    --> Success
        Run 'oc status' to view your app.

After creating the database as described above, scale it to zero replicas:

.. code-block:: bash

    $ oc scale --replicas=0 dc orders-test
    deploymentconfig "orders-test" scaled


Scaling the database in CI
^^^^^^^^^^^^^^^^^^^^^^^^^^

APPUiO should now be ready support our test steps in Jenkins. Before and after actually running the tests, we will need to scale the database to an appropriate amount of replicas. This can easily be done with the OpenShift Jenkins plugin.

To implement this behavior, we extend the Jenkinsfile as follows:

.. code-block:: groovy
    :caption: Jenkinsfile
    :linenos:
    :emphasize-lines: 14, 17, 24-30

    pipeline {
      agent any

      stages {
        stage('test') {
          agent {
            // run with the custom python slave
            // will dynamically provision a new pod on APPUiO
            label 'python'
          }

          steps {
            // scale the ephemeral orders-test database to 1 replica
            openshiftScale(depCfg: 'orders-test', replicaCount: '1')

            // sleep for 20s to give the db chance to initialize
            sleep 20

            // TODO: install dependencies

            // TODO: run tests
          }

          post {
            always {
                // scale the ephemeral orders-test database to 0 replicas
                // as it is ephemeral, all data will be lost
                openshiftScale(depCfg: 'orders-test', replicaCount: '0')
            }
          }
        }

        ...

      }
    }

As can be seen in the snippet, scaling a DeploymentConfig is as simple as using the ``openshiftScale()`` step with appropriate parameters (lines 14, 28). After scaling up the database, we need to add an additional 20 seconds of sleep time to give the database time to initialize (line 17).

As we want to scale down the database in any case (even if the pipeline fails), we need to put the command into the ``post`` section of the stage and inside an ``always`` block. The ``post`` section will be executed after a pipeline finishes, independent of its status. Next to ``always``, there are many other blocks that for example only get executed on failures (to send an email etc.).

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `OpenShift Jenkins Plugin [Github] <https://github.com/openshift/jenkins-plugin>`_


Running tests in CI
^^^^^^^^^^^^^^^^^^^

To actually run the tests in the pipeline, we need to install the Python (pip) dependencies and execute the test script. We also need to add environment variables that contain the database credentials, as the test script will be expecting these.

We end up with a complete version of the test stage after adding the steps for testing:

.. code-block:: groovy
    :caption: Jenkinsfile
    :linenos:
    :emphasize-lines: 4-9, 27, 30

    pipeline {
      agent any

      environment {
        DB_HOSTNAME = 'orders-test'
        DB_USERNAME = 'orders'
        DB_PASSWORD = 'secret'
        DB_DATABASE = 'orders'
      }

      stages {
        stage('test') {
          agent {
            // run with the custom python slave
            // will dynamically provision a new pod on APPUiO
            label 'python'
          }

          steps {
            // scale the ephemeral orders-test database to 1 replica
            openshiftScale(depCfg: 'orders-test', replicaCount: '1')

            // sleep for 20s to give the db chance to initialize
            sleep 20

            // install the application requirements
            sh 'pip3.6 install --user -r requirements.txt'

            // run the application tests with verbose output
            sh 'python3.6 -m unittest wsgi_test --verbose'
          }

          post {
            always {
              // scale the ephemeral orders-test database to 0 replicas
              // as it is ephemeral, all data will be lost
              openshiftScale(depCfg: 'orders-test', replicaCount: '0')
            }
          }
        }

        ...

      }
    }

The environment variables we specified inside the ``environment`` block (lines 4-9) are available in the environment of our Jenkins slave, where the Python test script can pick them up and connect to the database. Installing the dependencies and running said test script is as easy as adding two bash commands using the ``sh`` step (lines 27, 30).


Implementing the deployment stage
---------------------------------

The pipeline we have built so far will successfully test the application. After these tests finish without errors, we would like the pipeline to start and track a Source-To-Image build and deploy the newly created image (alongside its configuration). This section will explain our approach for implementing this.


Running an S2I build
^^^^^^^^^^^^^^^^^^^^

Starting an OpenShift build from Jenkins is as straightforward as the scaling of a deployment in the previous section. We can again make use of the OpenShift Jenkins Plugin using the command ``openshiftBuild()``. This command will start the build passed as a parameter and follow its execution. The pipeline will then only continue once the build has sucessfully finished.

After the build has finished without errors, we will want to manually trigger a deployment (as the automatic triggers on OpenShift will be disabled by our configuration). This can be done using the same plugin with the ``openshiftDeploy()`` command. A pipeline that implements those two steps could look as follows:

.. code-block:: groovy
    :caption: Jenkinsfile
    :linenos:
    :emphasize-lines: 18, 21

    pipeline {
      agent any

      stages {
        stage('test') {
          ...
        }

        stage('deploy-staging') {
          agent {
            // run with the custom python slave
            // will dynamically provision a new pod on APPUiO
            label 'python'
          }

          steps {
            // start a new openshift build
            openshiftBuild(bldCfg: 'orders-staging')

            // trigger a new openshift deployment
            openshiftDeploy(depCfg: 'orders-staging')
          }
        }
      }
    }


Replacing configuration objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: Contrary to the OpenShift Client Plugin used in the preceding section, the described OpenShift Jenkins Client Plugin is not preinstalled in the default Jenkins image you run on OpenShift. To be able to use the plugin, the default Jenkins image has to be customized using Source-To-Image. For more information, please refer to `Jenkins on Github <https://github.com/openshift/jenkins#installing-using-s2i-build>`_ and `our extended image <https://github.com/appuio/shop-example-jenkins>`_.

In between building the image with S2I and deploying it to APPUiO, we would like to update (replace) the configuration for our DeploymentConfig and Service. The simple functions of the OpenShift Jenkins Plugin don't allow this specific use case. However, there is another plugin that offers the functionality we need (the OpenShift Jenkins Client Plugin).

Using the OpenShift Jenkins Client Plugin, any command the official CLI supports can be used in Jenkins pipelines. This allows many more complicated use cases, but also increases the complexity of the pipeline, as blocks of *Scripted Pipeline* syntax need to be used and additional configuration has to be added (credentials).

After following the preceding chapter, Jenkins should already have an OpenShift token in its credential store. This token will be used by the Jenkins Client Plugin to connect with an instance of OpenShift (APPUiO in our case). The following snippet shows how we can connect to APPUiO with the Jenkins Client Plugin and replace our configuration objects:

.. code-block:: groovy
    :caption: Jenkinsfile
    :linenos:
    :emphasize-lines: 20-21, 23-33

    pipeline {
      agent any

      stages {
        stage('test') {
          ...
        }

        stage('deploy-staging') {
          agent {
            // run with the custom python slave
            // will dynamically provision a new pod on APPUiO
            label 'python'
          }

          steps {
            // start a new openshift build
            openshiftBuild(bldCfg: 'orders-staging')

            // replace the openshift config
            sh 'sed -i "s;CLUSTER_IP;172.30.57.24;g" docker/openshift/service.yaml'

            script {
              openshift.withCluster() {

                // tell jenkins that it has to use the added global token to execute under the jenkins serviceaccount
                // running without this will cause jenkins to try with the "default" serviceaccount (which fails)
                openshift.doAs('jenkins-oc-client') {
                  openshift.raw('replace', '-f', 'docker/openshift/deployment.yaml')
                  openshift.raw('replace', '-f', 'docker/openshift/service.yaml')
                }
              }
            }

            // trigger a new openshift deployment
            openshiftDeploy(depCfg: 'orders-staging')
          }
        }
      }
    }

The ``script`` block in the snippet above defines an area of *Scripted Pipeline* syntax. Everything enclosed inside the block is also valid Groovy syntax. ``openshift.withCluster()`` tells Jenkins to use the connection details defined for the default cluster in the global configuration. This will already be set if the Jenkins template on APPUiO is used.

After having defined which cluster to use, the Jenkins Client Plugin needs to connect with valid credentials. ``openshift.doAs('jenkins-oc-client')`` defines that Jenkins should connect to the cluster with the OpenShift token that is saved as *jenkins-oc-client* in the global credential store (we have added this token in the preceding chapter). Finally, the ``openshift.raw()`` command allows to pass in a command that will then be directly executed by the underlying *oc* binary (oc replace in our case).

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `OpenShift Jenkins Client Plugin [Github] <https://github.com/openshift/jenkins-client-plugin>`_


Deployment to multiple environments
-----------------------------------

The pipeline we have built up to now will test the application, build the image with S2I, update the configuration and then deploy the image to the staging environment. The way we handled multiple environments in Gitlab CI was by deploying the master branch to *staging*, every commit that was tagged to *preprod* and every commit that was tagged and manually promoted to *prod*.

Jenkins doesn't offer a simple solution for the behavior we implemented in Gitlab CI. Due to this, we implemented a slightly different strategy for the orders service. Everything on master will again be built for the *staging* environment. To promote to *preprod*, the master branch needs to be merged into the preprod branch (manually). To promote to *prod*, the preprod branch will need to be merged into the prod branch (master to prod would also be possible).

To only execute a stage for certain branches, one can make use of the Jenkins ``when`` directive. The ``openshiftTag()`` step can be used for tagging an OpenShift image (i.e. latest as stable). Implementing this for our pipeline, the final Jenkinsfile would be structured as follows:

.. code-block:: groovy
  :caption: Jenkinsfile
  :linenos:
  :emphasize-lines: 20-22, 33-34, 55-57, 68-69, 90-92

  pipeline {
    agent any

    stages {
      stage('test') {
        ...
      }

      stage('deploy-staging') {
        agent {
          // run with the custom python slave
          // will dynamically provision a new pod on APPUiO
          label 'python'
        }

        steps {
          ...
        }

        when {
          branch 'master'
        }
      }

      stage('deploy-preprod') {
        agent {
          // run with the custom python slave
          // will dynamically provision a new pod on APPUiO
          label 'python'
        }

        steps {
          // tag the latest image as stable
          openshiftTag(srcStream: 'orders', srcTag: 'latest', destStream: 'orders', destTag: 'stable')

          // replace the openshift config
          sh 'sed -i "s;CLUSTER_IP;172.30.57.24;g" docker/openshift/service.yaml'

          script {
            openshift.withCluster() {

              // tell jenkins that it has to use the added global token to execute under the jenkins serviceaccount
              // running without this will cause jenkins to try with the "default" serviceaccount (which fails)
              openshift.doAs('jenkins-oc-client') {
                openshift.raw('replace', '-f', 'docker/openshift/deployment.yaml')
                openshift.raw('replace', '-f', 'docker/openshift/service.yaml')
              }
            }
          }

          // trigger a new openshift deployment
          openshiftDeploy(depCfg: 'orders-preprod')
        }

        when {
          branch 'preprod'
        }
      }

      stage('deploy-prod') {
        agent {
          // run with the custom python slave
          // will dynamically provision a new pod on APPUiO
          label 'python'
        }

        steps {
          // tag the stable image as live
          openshiftTag(srcStream: 'orders', srcTag: 'stable', destStream: 'orders', destTag: 'live')

          // replace the openshift config
          sh 'sed -i "s;CLUSTER_IP;172.30.57.24;g" docker/openshift/service.yaml'

          script {
            openshift.withCluster() {

              // tell jenkins that it has to use the added global token to execute under the jenkins serviceaccount
              // running without this will cause jenkins to try with the "default" serviceaccount (which fails)
              openshift.doAs('jenkins-oc-client') {
                openshift.raw('replace', '-f', 'docker/openshift/deployment.yaml')
                openshift.raw('replace', '-f', 'docker/openshift/service.yaml')
              }
            }
          }

          // trigger a new openshift deployment
          openshiftDeploy(depCfg: 'orders-prod')
        }

        when {
          branch 'prod'
        }
      }
    }
  }

.. warning:: Using a strategy like this introduces possibility for errors. The commits that are being merged to preprod or prod might not at all times reflect the status of the actual image that is being deployed. The image that is promoted to preprod or prod will be based on the last commit to the master branch that has been built successfully instead of the last one merged in. If possible, the strategy we would recommend would be using git tags and manual promotion.


.. admonition:: Relevant Readings/Resources
    :class: note

    #. `Building tags [Jenkins Issues] <https://issues.jenkins-ci.org/browse/JENKINS-34395>`_
    #. `Using when in Jenkins [Jenkins Docs] <https://jenkins.io/doc/book/pipeline/syntax/#when>`_
