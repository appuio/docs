Building a container
====================

The process of dockerizing an application has been quite straightforward for the services we have seen so far. This process will get a little bit more complex for the users service. As the users service is an Elixir application, it will run on the Erlang VM once deployed. Erlang applications have the property that they need to be compiled for release on the same architecture as they will be run on. This basically means that we will need to compile the app inside the same (or a very similar) container environment as we will be running it in.

A possibility for achieving this quite easily would be compiling the application right inside the main Dockerfile. We have already described earlier that this is less than optimal for size as well as security. What we will do instead is use two separate docker containers based on the same architecture: one for testing and compiling the application sources, the other for running the application release (with only minimal dependencies).

Our builder and runtime images will be based on `Alpine Linux <https://alpinelinux.org>`_. Alpine is a Linux distribution that is built specifically with image size and security in mind, which often makes it the platform of choice for containers and microservices. The following two sections will shortly describe how we can create our two images based on Alpine.


The builder image
-----------------

The builder image is a docker image based on Alpine that contains all the dependencies that we might need for testing and compiling the Elixir application to an Erlang release.

.. code-block:: docker
    :caption: Dockerfile
    :linenos:
    :emphasize-lines: 1-2

    # extend alpine
    FROM alpine:3.5

    # specify the elixir version
    ENV ELIXIR_VERSION 1.4.2
    ENV MIX_ENV prod
    ENV PORT 4000

    # install erlang and elixir
    RUN apk --update add --no-cache --virtual .build-deps wget ca-certificates && \
        apk add --no-cache \
            make \
            g++ \
            erlang \
            erlang-crypto \
            erlang-syntax-tools \
            erlang-parsetools \
            erlang-inets \
            erlang-ssl \
            erlang-public-key \
            erlang-eunit \
            erlang-asn1 \
            erlang-sasl \
            erlang-erl-interface \
            erlang-dev && \
        wget --no-check-certificate https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip && \
        mkdir -p /opt/elixir-${ELIXIR_VERSION}/ && \
        unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ && \
        rm Precompiled.zip && \
        apk del .build-deps

    # add the elixir installation to path
    ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin

    # initialize hex and rebar
    RUN erl && \
        mix local.hex --force && \
        mix local.rebar --force

    # add a new dir for the app
    RUN mkdir -p /app/source
    WORKDIR /app/source

    # run shell as default command
    CMD ["/bin/sh"]

The most important part of this image is the declaration that we are going to use Alpine with a specific version and that we are going to use that same declaration for the runtime image. This guarantees that we will be able to run the built release inside the runtime image.

The remaining part of the Dockerfile is structured as follows:

Lines 4-7:
    Specify the version of Elixir that will be installed later on. Set the MIX_ENV such that Elixir compiles for production and specify the default application port.

Lines 9-25:
    Install Erlang and additional Erlang extensions that might be necessary for building the application.

Lines 26-33:
    Install the previously specified version of Elixir.

Lines 35-38:
    Initialize the Elixir mix build tool as this can shave some time off the actual builds run inside the container.

Lines 40-42:
    Add a new base directory where the application sources will reside. Define this as the default working directory.

This image might now be used to run mix commands that test or compile the application. We will cover the exact commands in the next chapter about running the containers.


The runtime image
-----------------

As we don't want to run our application inside the builder image we just built, we also have to create a runtime image that will actually run our application in production. As this image will be running on APPUiO, we will have to adhere to the guidelines set for images on the OpenShift platform (as we have already seen in earlier chapters).

.. code-block:: docker
    :caption: Dockerfile
    :linenos:
    :emphasize-lines: 1-2

    # extend alpine
    FROM alpine:3.5

    # create new user with id 1001 and add to root group
    RUN adduser -S 1001 -G root && \
        mkdir -p /app/var

    # expose port 4000
    EXPOSE 4000

    # environment variables
    ENV HOME /app
    ENV VERSION 0.0.1

    # install ncurses-libs
    # it seems to be a runtime dependency
    RUN set -x && \
        apk --update --no-cache add \
            ncurses-libs \
            postgresql-client

    # change to the application root
    WORKDIR /app

    # inject the entrypoint
    COPY entrypoint.sh /app/entrypoint.sh

    # copy the release into the runtime container
    COPY _build/prod/rel/docs_users/releases/${VERSION}/docs_users.tar.gz /app/docs_users.tar.gz

    # make the entrypoint group executable
    RUN chown -R 1001:root /app && \
        chmod g+x /app/entrypoint.sh
    
    # switch to user 1001 (non-root)
    USER 1001

    # extract the release
    RUN tar xvzf docs_users.tar.gz && \
        rm -rf docs_users.tar.gz && \
        chmod -R g+w /app

    # define the custom entrypoint
    # this will wait for postgres to be up
    # and execute /app/docs_users $@ subsequently
    ENTRYPOINT ["/app/entrypoint.sh"]

    # run the release in foreground mode
    # such that we get logs to stdout/stderr
    CMD ["/app/bin/docs_users", "foreground"]

Lines 4-6, 31-36, 41:
    Create a numerical user and the necessary directory structure and permissions to allow the application to run as an arbitrary non-root user.

Lines 15-20:
    Install the absolute necessary runtime dependencies of the application. The ncurses library provides tools for display of shell menus and is needed by the Erlang release. Our custom entrypoint that checks for a database connection is going to need the postgresql-client later on.

Lines 128-129:
    Inject the compiled application release into the container. How to actually generate this release will be covered in the next chapter.

