Running the container
====================

.. note:: This is an early version and still work in progress!

.. todo::
    * Optimize the structure of this..

The source-to-image builder we created in the last section should now allow us to package our application into a runnable container.

To try building the API with our custom builder, we first need to "build the builder" by running ``docker build`` in our builder repository:

``docker build . -t scala-play-s2i``

We can then execute ``s2i build`` in our application repository:

``s2i build . scala-play-s2i api``

This will have created a runnable image called ``api``. To run the image, we can use ``docker run`` with a custom command that refers to the run script:

``docker run -it --rm api /usr/libexec/s2i/run``