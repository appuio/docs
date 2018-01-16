Building a container
====================

As previously described, the API service will be built using the source-to-image strategy. This approach was chosen to showcase how a custom S2I build process might be implemented, even if it might not be optimal for this specific use case.

The process for building our application should roughly look as follows:

#. Inject the application sources into the **S2I builder**
#. Run the embedded **assemble** script to compile the application
#. Commit the container (essentially updating the image)
#. Run the container using its embedded **run** script

The OpenShift project provides an s2i binary that automatically executes those steps for us. This basically means that if we run ``s2i build ...`` with the right parameters, it will use the specified builder image to create a runnable image **based on our sources**.

The following sections will go into the necessary preparations for the s2i command to work. This includes creating a custom s2i builder image as well as using the s2i binary to build the service with said image.


Creating a custom S2I builder
-----------------------------

To initialize a new source-to-image builder, we can use the handy ``s2i create scala-play-s2i .`` command. This will generate a new S2I builder project (called *scala-play-s2i*) that includes the necessary directory structure as well as some baseline assemble and run scripts.

The following sections will describe how we can extend and optimize this baseline for our use case.

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `S2I Repository [GitHub] <https://github.com/openshift/source-to-image>`_
    #. `Creating builder images [GitHub] <https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md>`_
    #. :openshift:`Custom Builder [OpenShift Docs] <creating_images/custom.html>`
    #. :openshift:`S2I Requirements [OpenShift Docs] <creating_images/s2i.html>`


The assemble script
^^^^^^^^^^^^^^^^^^^

The assemble script is the first script that will be run bafter the S2I binary has created the container and injected the sources. Its responsibility is to ensure that the container contains an executable version of the application (built, compiled etc.) by the end of the script. After the assemble script finishes, S2I will commit the container (effectively creating a new version of the image).

What follows is a snippet with the most relevant commands of our assemble script:

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

As a first step, the assemble script gets the application sources from the temporary directory in **/tmp/src** (the directory where S2I injects sources) and removes the temporary directory. We don't want anything that unnecessarily bloats the docker image later on, as it will be large enough as is.

The following commands compile the Scala application with the SBT build tool and ensure that the root group (groupid 0) is allowed to run the necessary executables, as OpenShift will run the application with a random userid and groupid 0 (as described in the preceding chapter).


The run script
^^^^^^^^^^^^^^

The run script serves as an entrypoint for the container and will be set as the resulting container's default command. This basically means that next to running the main executable, the run script can also be used to do some preparations beforehand.

In our simple use case, the run script will be used to start the Play! backend and pass it some parameters. As Play! automatically runs database migrations as soon as it is started, it would crash if the associated database is not yet ready. The easiest way to handle this would be to simply ignore it, which would cause OpenShift to restart the service over and over until the database is ready.

Even though this would work, we will extend our run script such that this process is a little bit more "clean". Before finally running the main executable, the run script should check the connection to the database and wait until the database is fully initialized and ready to accept connections.

A run script that implements this using environment variables for configuration could look as follows:

.. code-block:: bash
    :caption: .s2i/bin/run

    #!/bin/bash -e

    ...

    # if no port is set, use default for postgres
    DB_PORT=${DB_PORT:-5432}

    # save db credentials to pgpass file
    # such that the psql command can connect
    echo "$DB_HOSTNAME:$DB_PORT:$DB_DATABASE:$DB_USERNAME:$DB_PASSWORD" > ~/.pgpass
    chmod 600 ~/.pgpass
    export PGPASSFILE=~/.pgpass

    # concatenate the correct db connection string
    DB_URL="jdbc:postgresql://$DB_HOSTNAME:$DB_PORT/$DB_DATABASE"

    # sleep as long as postgres is not ready yet
    until psql -h "$DB_HOSTNAME" -U "$DB_USERNAME"; do
        >&2 echo "Postgres is unavailable - sleeping"
        sleep 1
    done

    # as soon as postgres is up, execute the application with given params
    # include the correct db connection string
    >&2 echo "Postgres is up - executing command"
    exec /opt/app-root/src/target/universal/stage/bin/docs_example_api -Dslick.dbs.default.db.url=$DB_URL

.. note:: Even though our solution might be an improvement, it is by far not the best solution to this problem. It is considered good practice to develop applications such that they are resilient to database failures and will handle such failures appropriately (holds for all dependencies).


The Dockerfile
^^^^^^^^^^^^^^

With both the assemble and run scripts in place, we can continue to the main part of the S2I builder. As the S2I builder is basically just another docker container, we will need to create a Dockerfile that includes all the dependencies of our application (compile-time as well as runtime depencencies). The Dockerfile has to adhere to some rules if it should later be usable in an OpenShift environment.

.. code-block:: docker
    :caption: Dockerfile
    :linenos:
    :emphasize-lines: 2, 5-11, 37, 40-42

    # extend the base image provided by OpenShift
    FROM openshift/base-centos7

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
        SBT_VERSION=0.13.15 \
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
    OpenShift provides a baseline docker image (CentOS with common dependencies) that can be extended to build custom S2I builders. As we generally won't be optimizing for space in a source-to-image context (we already decided that we will include compile-time dependencies in our runtime image), we are depending on this image in our Dockerfile.

Lines 6-12:
    The labels following the FROM directive are descriptive metadata that is only needed in an OpenShift context. They allow OpenShift to provide a description for our image as well as to inject the sources in the right place.

Lines 23-35:
    Setup and initialize dependencies like Java, SBT and the postgres-client (for usage in the run script).

Lines 37-38:
    Inject the S2I scripts (assemble, run etc.). S2I and OpenShift will default this path to ``/usr/libexec/s2i`` and inject it via the $STI_SCRIPTS_PATH environment variable.

Lines 40-43:
    Ensure that the permissions allow running the image on OpenShift (no root).

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `CentOS base image [Docker Hub] <https://hub.docker.com/r/openshift/base-centos7>`_
    #. :openshift:`Guidelines for creating images [OpenShift Docs] <creating_images/guidelines.html>`


Incremental builds
^^^^^^^^^^^^^^^^^^

In comparison with a Gitlab CI pipeline like the one we built for the webserver, the above S2I configuration loses out regarding time-savings through caching (the assemble script redownloads the dependencies on each run).

To achieve the same caching behavior as in our Gitlab CI pipelines, we will have to add another S2I script called **save-artifacts** that extracts the dependencies we want to cache. OpenShift can later be configured to automatically inject those dependencies before running the assemble script.

A stub for the save-artifacts script should already have been created in the .s2i/bin directory. We will need to update the paths it extracts to contain the .ivy cache folder, as this is where the SBT build tool caches the dependencies.

.. code-block:: bash
    :caption: .s2i/bin/save-artifacts

    #!/bin/sh -e
    # The save-artifacts script streams a tar archive to standard output.
    # The archive contains the files and folders you want to re-use in the next build.
    tar cf - .ivy2 target .sbt

If S2I has been configured correctly, it will inject the saved "artifacts" on the next run. The directory it injects them to will normally be **/tmp/artifacts**. Our assemble script will need to be extended such that it recognizes those artifacts and reuses them:

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

This configuration will allow us to run **incremental builds** on OpenShift, which basically means that the artifacts of the previous build will be reused.

.. admonition:: Relevant Readings/Resources
    :class: note

    #. :openshift:`Incremental Builds [OpenShift Docs] <dev_guide/builds/build_strategies.html#incremental-builds`
