Deploying to APPUiO
==================

.. note:: This is an early version and still work in progress!

.. todo::
    * refactor notes

Creating a custom S2I builder
----------------------------

* http://docs.appuio.ch/en/latest/how-tos.html#how-to-use-a-private-repository-on-e-g-github-to-run-s2i-builds
    * better use https for initially creating as ssh does seem to be very unreliable...
* oc new-build https://git.vshn.net/roland.schlaefli/play_scala_s2i.git --name="play-scala-s2i" --strategy="docker"
    * needs specification of credentials for initial creation
    * change source to ssh url and add sourceSecret in yaml afterwards

Running S2I builds
-----------------

* oc new-app play-scala-s2i~git@git.vshn.net:appuio/docs_example_api.git --name="api" --strategy="source"
* oc set build-secret --source bc/api sshsecret
    * only works from 1.4/3.4 upwards!
    * for older versions add "sourceSecret: name: sshsecret" in source key
* update resources (cpu/ram) as the JVM will need at least 1Gi
    * resources: limits: cpu: 500m memory: 1Gi requests: cpu: 100m memory: 512Mi
* add the play configuration secret as an environment variable (or a secret?)
* activate incremental build by adding "incremental: true" in sourceStrategy
* extended builds are not very useful in their current state as incremental builds cannot be used simultaneously