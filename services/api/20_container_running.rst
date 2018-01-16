Running the container
=====================

The source-to-image builder we created in the last section should allow us to package our application into a runnable container. We are going to use our Vagrant box to run builds locally, as it already includes an appropriate version of the S2I binary.

After starting the box and connecting with ``vagrant ssh``, we can run the following commands:

**Build the builder**: ``docker build . -t scala-play-s2i`` in the builder repository.

This builder is now ready to build our application sources:

**Running S2I**: ``s2i build --incremental=true . scala-play-s2i shop-example-api`` in the service repository

The ``--incremental`` flag will use the *save-artifacts* script for caching dependencies. After a successful S2I build, the resulting container can be run as follows:

**Running the container**: ``docker run -it shop-example-api:latest --name api``

You should now have a working API which you can reach on ``VAGRANT_VM_IP:9000``.

In the next section, we will implement a Gitlab CI pipeline that tests the application and delegates the S2I build process to APPUiO.

.. admonition:: Relevant Readings/Resources
    :class: note

    #. `S2I CLI reference [GitHub] <https://github.com/openshift/source-to-image/blob/master/docs/cli.md>`_
