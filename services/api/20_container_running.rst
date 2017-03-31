Running the container
====================

.. note:: This is an early version and still work in progress!

.. todo::
    * explain how to build with S2I in vagrant

* creating a S2I builder
    * building the builder locally: docker build . -t play-scala-s2i
* building the application using S2I
    * locally: s2i build . play-scala-s2i docs_example_api
    * reference to deployment section