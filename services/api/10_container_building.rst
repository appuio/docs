Building a container
===================

.. note:: This is an early version and still work in progress!

As previously described, the API service will be built using the source-to-image strategy. This approach was chosen to showcase how a custom S2I build process might be implemented, even if it might not be optimal for this use case. 

If we build our application, the process should roughly look as follows:

#. Inject the application sources into the **S2I builder**
#. Run the embedded *assemble* script to compile the application
#. Commit the container (essentially updating the image)
#. Run the container using its embedded *run* script

The OpenShift project provides an s2i binary that automatically executes those steps for us. This basically means taht if we run ``s2i build ...`` with the right parameters, it will use the specified builder image to create a runnable image from our sources.

The following sections will go into the necessary preparations for the s2i command to work. This includes creating a custom s2i builder image with custom assemble and run scripts as well as using the s2i binary to build the API service.


Creating a custom S2I builder
----------------------------

To initialize a new source-to-image builder repository, we can use the handy ``s2i create custom-builder-name .`` command. This will generate a new S2I builder project that includes the necessary directory structure as well as some sample assemble and run scripts. Those can then be used as a baseline for further developments.

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `S2I CLI reference [GitHub] <https://github.com/openshift/source-to-image/blob/master/docs/cli.md>`_
    #. `Creating builder images [GitHub] <https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md>`_
    #. `Custom Builder [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/creating_images/custom.html>`_


The assemble script
^^^^^^^^^^^^^^^^^^

The assemble script ensures that an executable version of the application (built, compiled etc.) is saved in the application's home directory, where it can later be executed through the run script.

The following is a snippet with the most relevant commands of our assemble script:

.. code-block:: bash
    :caption: .s2i/bin/assemble

    #!/bin/bash -e

    ...

    echo "---> Installing application source..."
    cp -Rf /tmp/src/. ./
    rm -rf /tmp/src

    echo "---> Building application from source..."
    sbt -ivy ~/.ivy2 -verbose -mem 1024 clean stage
    chgrp 0 target/universal/stage/bin/*
    chmod g+x target/universal/stage/bin/*
    chmod +x entrypoint.sh

As a first step, the assemble script gets the application sources from the temporary directory in **/tmp/src** (the directory where S2I injects sources) and removes the temporary directory. We don't want anything that unnecessarily bloats the docker image later on, as it will be large enough as is.

The following commands compile the Scala application with the SBT build tool and ensure that the root group (groupid 0) is allowed to run the necessary executables, as OpenShift will run the application with a random userid and groupid 0 (as described in the preceding chapter).


The run script
^^^^^^^^^^^^^

The run script provides a shorthand for possibly longer commands that start up the application server. The run script for the API service is composed as follows:

.. code-block:: bash
    :caption: .s2i/bin/run

    #!/bin/bash -e
    # execute the application
    exec "/opt/app-root/src/entrypoint.sh /bin/bash -c '/opt/app-root/src/target/universal/stage/bin/docs_example_api -Dpidfile.path=/tmp/app.pid'"

In case of the API service, the run command will execute an entrypoint script that checks for a connection to the PostgreSQL database. Once the connection is established, the entrypoint will run the API executable. This ensures that the application server is only started after the database has been successfully initialized.


The Dockerfile
^^^^^^^^^^^^^^

With both the assemble and run scripts in place, we can continue to the main part of the S2I builder. As the S2I builder is basically just another docker container, we will need to create a Dockerfile that includes all the dependencies of our application (compile-time as well as runtime depencencies). The Dockerfile must also adhere to some rules if it should later be usable in an OpenShift environment.

.. code-block:: docker
    :caption: Dockerfile
    :linenos:
    :emphasize-lines: 2, 6-12, 38, 41-43

    # extend the base image provided by OpenShift
    FROM openshift/base-centos7

    # ENV STI_SCRIPTS_PATH /usr/libexec/s2i
    # set labels used in OpenShift to describe the builder image
    LABEL \
        io.k8s.description="Platform for building Scala Play! applications" \
        io.k8s.display-name="scala-play" \
        io.openshift.expose-services="9000:http" \
        io.openshift.tags="builder,scala,play" \
        # location of the STI scripts inside the image.
        io.openshift.s2i.scripts-url=image://$STI_SCRIPTS_PATH

    # specify wanted versions of Java and SBT
    ENV JAVA_VERSION=1.8.0 \
        SBT_VERSION=0.13.13.1-1 \
        HOME=/opt/app-root/src \
        PATH=/opt/app-root/bin:$PATH

    # expose the default Play! port
    EXPOSE 9000

    # add the repository for SBT to the yum package manager
    COPY bintray--sbt-rpm.repo /etc/yum.repos.d/bintray--sbt-rpm.repo

    # install Java and SBT
    RUN yum install -y \
            java-${JAVA_VERSION}-openjdk \
            java-${JAVA_VERSION}-openjdk-devel \
            sbt-${SBT_VERSION} \
            postgresql && \
        yum clean all -y

    # initialize SBT
    RUN sbt -ivy ${HOME}/.ivy2 -debug about

    # copy the s2i scripts into the image
    COPY ./.s2i/bin $STI_SCRIPTS_PATH

    # chown the app directories to the correct user
    RUN chown -R 1001:0 $HOME && \
        chmod -R g+rw $HOME && \
        chmod -R g+rx $STI_SCRIPTS_PATH

    # switch to the user 1001
    USER 1001

    # show usage info as a default command
    CMD ["$STI_SCRIPTS_PATH/usage"]

This Dockerfile contains some S2I-specific configuration:

Lines 1-2:
    OpenShift provides a baseline docker image (CentOs with common dependencies) that can be extended to build custom S2I builders. As we generally won't be optimizing for space in a source-to-image context (we already accepted that we will include compile-time dependencies in our runtime image), we are depending on this image in our Dockerfile.

Lines 6-12:
    The labels following the FROM directive are descriptive metadata that is only needed in an OpenShift context. They allow OpenShift to provide a description for our image as well as to inject the sources in the right place.

Lines 23-35:
    Setup and initialize the dependencies like Java, SBT and the postgres-client (for the entrypoint).

Lines 37-38:
    Inject the S2I scripts (assemble, run etc.). S2I and OpenShift will default this path to ``/usr/libexec/s2i`` and inject it via the $STI_SCRIPTS_PATH environment variable.

Lines 40-43:
    Ensure that the permissions allow running the image on OpenShift.

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `CentOS base image [Docker Hub] <https://hub.docker.com/r/openshift/base-centos7>`_
    #. `Guidelines for creating images [OpenShift Docs] <https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html>`_


Incremental builds
^^^^^^^^^^^^^^^^^

In comparison with a Gitlab CI pipeline like the one we built for the webserver, the above S2I configuration loses out regarding the time-savings through caching (the assemble script redownloads all the dependencies on each run).

To achieve the same caching behavior as in our Gitlab CI pipelines, we will have to add another S2I script called **save-artifacts** that extracts the dependencies that we want to cache. OpenShift can later be configured to automatically inject those dependencies before running the assemble script, which will save time.

A stub for the save-artifacts script should already have been created in the .s2i/bin directory. We will need to update the paths it extracts to contain the .ivy cache folder, as this is where SBT caches the dependencies.

.. code-block:: bash
    :caption: .s2i/bin/save-artifacts

    #!/bin/sh -e
    # The save-artifacts script streams a tar archive to standard output.
    # The archive contains the files and folders you want to re-use in the next build.
    tar cf - .ivy2 target .sbt

If S2I has been configured correctly, it will inject the saved "artifacts" on the next run. The directory it injects them to will normally be **/tmp/artifacts**. Our assemble script will need to be extendes such that it recognizes those artifacts and reuses them:

.. code-block:: bash
    :caption: .s2i/bin/assemble

    #!/bin/bash -e
    # Restore artifacts from the previous build (if they exist).
    if [ "$(ls /tmp/artifacts/ 2>/dev/null)" ]; then
        echo "---> Restoring build artifacts..."
        cp -Rn /tmp/artifacts/. ./
        rm -rf /tmp/artifacts
    fi

    echo "---> Installing application source..."
    cp -Rf /tmp/src/. ./
    rm -rf /tmp/src

    echo "---> Building application from source..."
    sbt -ivy ~/.ivy2 -verbose -mem 1024 clean stage
    chgrp 0 target/universal/stage/bin/*
    chmod g+x target/universal/stage/bin/*
    chmod +x entrypoint.sh

This configuration will allow us to run **incremental builds** later on, which basically means that some parts of the previous build will be reused as described in this section.
