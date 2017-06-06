Running the container
====================

Now that we have created a builder as well as a runtime image, we can discuss the commands used for actually testing, building and running the users service.

Compilation
-----------

To run the Elixir application in production, we have to compile the sources and bundle them into an Erlang release. An Erlang release provides a way to run the application based on standalone binaries. These binaries contain the Erlang runtime and everything the application needs to run. This bundling of the Erlang runtime into the release is the main reason that we need to run it in the same environment as we built it, as the runtime is built specifically for the architecture.

The steps for building our application with the builder image are as follows:

#. start the builder container and inject the application sources as a volume
#. cleanup previous build artifacts
#. download the application dependencies using ``mix deps.get``
#. build a release for the application using ``mix release``

All of these steps can be combined into a single docker run command:

.. code-block:: bash

  docker run -t --rm \
    --volume "/opt/git/services/users:/app/source" \
    appuio/shop-example-users-builder \
    /bin/sh -c "mix clean --deps;mix deps.get;MIX_ENV=prod mix release --env=prod"

After the above command finishes, the application directory will contain a deployable release in the ``_build`` directory (this will later be injected into the runtime container). Be aware that the built release can only be run inside the runtime container.


Testing
-------

The tests we included with the users microservice are integration tests based on a successful connection to PostgresSQL. This means that to test the application with the builder image, we will also need to spin up a temporary database container. We can simplify this process by using docker-compose to define this dependency between builder container and database:

.. code-block:: yaml
    :caption: docker-compose.dev.yml
    :linenos:
    :emphasize-lines: 4, 16

    version: "2.1"
    services:
      users:
        image: appuio/shop-example-users-builder
        command: /bin/sh -c "mix deps.get;mix ecto.migrate;mix test"
        environment:
          DB_USERNAME: users
          DB_PASSWORD: secret
          DB_DATABASE: users
          DB_HOSTNAME: users-db
          MIX_ENV: prod
          SECRET_KEY: "SOME_SECRET"
        ports:
          - "4000:4000"
        volumes:
          - /opt/git/services/users:/app/source

      users-db:
        image: postgres:9.5-alpine
        environment:
          POSTGRES_USER: users
          POSTGRES_PASSWORD: secret

As we can see, this is quite a simple compose definition. We define a database container and spin up an instance of the users-builder, passing in the credentials for the database as well as some more application configuration in environment variables. Additionally, the application sources are injected by using a volume and mapping it to /app/source.

We can then start up the containers using ``docker-compose up -d docker-compose.dev.yml`.


Running
-------

Besides compiling a release and tested the application, we would also like to be able to run the application locally. Based on the release we have already built, we can now build the main Dockerfile and start up a container. As the Elixir appliction depends on a database, we are again going to use docker-compose:

.. code-block:: yaml
    :caption: docker-compose.yml
    :linenos:
    :emphasize-lines: 4

    version: "2.1"
    services:
      users:
        build: .
        environment:
          DB_HOSTNAME: users-db
          DB_USERNAME: users
          DB_PASSWORD: secret
          DB_DATABASE: users
          SECRET_KEY: "SOME_SECRET"
        ports:
          - "4000:4000"

      users-db:
        image: postgres:9.5-alpine
        environment:
          POSTGRES_USER: users
          POSTGRES_PASSWORD: secret

This compose file will start a database container, build the runtime image and start it while passing in database credentials and a secret key. After the process finishes, the application will be running and listening on port 4000.

Now that we have done this locally, we will start building out a CI pipeline that can help us automate these steps.
