Building a container
====================

The first thing we need to achieve such that we can later deploy our application to APPUiO is packaging it into a docker container. The Dockerfile for this is quite simple:

.. code-block:: docker
    :caption: docs_webserver/Dockerfile
    :linenos:
    :emphasize-lines: 6, 12, 18

    # extend the official nginx image from https://hub.docker.com/_/nginx/
    # use mainline as recommended by devs and alpine for reduced size
    FROM nginx:1.11-alpine

    # create new user with id 1001 and add to root group
    RUN adduser -S 1001 -G root

    # expose port 9000
    EXPOSE 9000

    # copy the custom nginx config to /etc/nginx
    COPY docker/nginx.conf /etc/nginx/nginx.conf

    # copy artifacts from the public folder into the html folder
    COPY build /usr/share/nginx/html

    # switch to user 1001 (non-root)
    USER 1001

Most commands should be understandable by their respective comments (for a reference see #1).

There is one very important concept we would like to emphasize: OpenShift enforces that the main process inside a container must be executed by an unnamed user with numerical id (see #2). This is due to security concerns about the permissions of the root user inside a container as it might break out and access the host. If the webserver is ultimately deployed to OpenShift, the platform will assign a random numerical id in place of the defined id 1001.

Due to these security restrictions, the official nginx image has to be configured differently, as it normally wants to run as root (which would cause the deployment on OpenShift to fail). We need to use a customized nfinx configuration such that the process doesn't get killed by OpenShift. Said configuration is copied into the container on line 12 of the above Dockerfile (see #3 and #4).

The most important customizations needed in order to run nginx on APPUiO are shown in the source extract below:

.. code-block:: nginx
    :caption: docs_webserver/docker/nginx.conf
    :linenos:
    :emphasize-lines: 7, 10, 17, 20-24, 29-30

    # ...

    # specifying the user is not necessary as we change user in the Dockerfile
    # user  nginx;

    # log errors to stdout
    error_log  /dev/stdout warn;

    # save the pid file in tmp to make it accessible for non-root
    pid        /tmp/nginx.pid;

    http {

        ...

        # log access to stdout
        access_log  /dev/stdout main;

        # set cache locations that are accessible to non-root
        client_body_temp_path /tmp/client_body;
        fastcgi_temp_path /tmp/fastcgi_temp;
        proxy_temp_path /tmp/proxy_temp;
        scgi_temp_path /tmp/scgi_temp;
        uwsgi_temp_path /tmp/uwsgi_temp;

        server {
            # the server has to listen on a port above 1024
            # non-root processes may not bind to lower ports
            listen *:9000 default_server;
            listen [::]:9000 default_server;
            server_name _;

            location / {
                # ...
            }
        }
    }

The next section will show how we can build the application sources and run the application as a docker container (using the provided Vagrant box).

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Dockerfile reference [Docker Docs] <https://docs.docker.com/engine/reference/builder>`_
    #. :openshift:`Supporting Arbitrary User IDs [OpenShift Docs] <creating_images/guidelines.html#openshift-container-platform-specific-guidelines>`
    #. `Running nginx as a non-root user [ExRatione] <https://www.exratione.com/2014/03/running-nginx-as-a-non-root-user>`_
    #. `Livingdocs nginx.conf [GitHub] <https://github.com/upfrontIO/livingdocs-docker/blob/master/editor/docker/nginx.conf>`_
