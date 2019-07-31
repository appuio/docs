Unifi-Controller
================

To manage Ubiquiti UniFi Wifi- and Networking devices you can deploy your own Network Management Controller.

There is a readily available docker image (https://hub.docker.com/r/jacobalberty/unifi/) containing both the UniFi Software and MongoDB Database running as non-root.

To deploy this with a proper SSL certificate follow these easy steps:

#. Log in to https://console.appuio.ch/ and choose your project you want to deploy your controller in

#. Choose "Add to project" at the top-right and "Deploy Image" in the menu

.. image:: unifi1.png

#. Enter "jacobalberty/unifi:latest" in the Image Name and click the magnifying glass button on the right

.. image:: unifi2.png

#. You can customize the Name if you want to, I'll use the default "unifi" name

#. Set the following environment variables::

     BIND_PRIV=false
     RUNAS_UID0=false
     JVM_MAX_THREAD_STACK_SIZE=1280k
     TZ=Europe/Zurich (or whatever your timezone is)

.. image:: unifi3.png

#. Click "Deploy" and then "Close"

#. Open the newly created Deployment Configuration, e.g. via Applications -> Deployments -> unifi -> Configuration

#. Choose "Actions" -> "Pause Rollouts"

.. image:: unifi4.png

#. Choose "Actions" -> "Edit"

.. image:: unifi5.png

#. Set the deployment strategy type to "Recreate", acknowledge the popup and Save at the bottom

.. image:: unifi6.png

.. image:: unifi7.png

#. back in the Configuration Tab: delete the "unifi-1" storage volume

.. image:: unifi8.png

#. Choose "Actions" -> "Add storage"

#. If you already have a persistent volume created for the unifi controller choose it here, or click "create storage" to create a new one

.. image:: unifi9.png

#. I chose the name "unifi" and size "10" GB, continue with "Create"

.. image:: unifi10.png

#. back in the volume dialog: set mount path "/unifi" and volume name "unifi-1", then "Add"

.. image:: unifi11.png

#. Choose "Actions" -> "Edit Resource Limits"

#. Set CPU Request: 100, Limit: 500 and RAM Requiest: 200, Limit: 500

.. image:: unifi12.png

#. Choose "Actions" -> "Edit Health Checks"

#. Add both readiness and liveness probes with Type: HTTP, Use HTTPS, Port 8443, Initial Delay 30s

.. image:: unifi13.png

#. Resume rollouts

.. image:: unifi14.png

#. Wait until the deployment rollout is done

.. image:: unifi15.png

#. the controller will have created a new, self-signed SSL-certificate on first start. We have to get this certificate to trust it. I used the CLI-Tools for this: copy login command on the top-right
.. image:: unifi16.png

#. paste the login command into a Terminal window, then `oc get pods -l app=unifi` to get the pod name and `oc port-forward unifi-2-4jm9g 8443:8443` (substituting your pod name in the command) to open a connection from your computer to the running unifi controller instance

.. image:: unifi17.png

#. open another Terminal window and enter `openssl s_client -connect 127.0.0.1:8443` to connect to the pod and output the SSL-certificate. Copy the certificate (all the lines from "-----BEGIN CERTIFICATE" up to and includiniig "-----END CERTIFICATE-----") from the output

.. image:: unifi18.png

#. Open "Applications" -> "Routes" and "Create Route" from the top-left.

#. I named the new route "unifi", entered the hostname my controller should be reachable at in the end ("arskacontroller.appuioapp.ch"), selected the Service "unifi", Port 8443, Enable Security, TLS-Termination "Re-encrypt", Insecure "Redirect" and paste the copied certificate from above in the "Destination CA Certificate" field. Then click "Create".

.. image:: unifi19.png

#. The access-points I bought were running firmware 3.7.58.6385. To connect ("adopt" or "inform") these to the controller another route without SSL is needed: "Create route", Name "unifi-inform", Hostname "arskainform.appuioapp.ch", Service "unifi", Port "8080". For access-points with firmware >4 this is not necessary.

.. image:: unifi20.png

#. we can connect to the controller to do the setup wizard using the first route created, https://arskacontroller.appuioapp.ch in my case

#. To connect a access-point with firmware version 3.x/4.x: ssh ubnt@ip-address-of-ap, password ubnt, `set-inform http://arskainform.appuioapp.ch/inform`

#. To connect a access-point with firmware version 4.x: ssh ubnt@ip-address-of-ap, password ubnt, `set-inform https://arskacontroller.appuioapp.ch/inform`

#. in both cases the access-point appears as "pending adoption" in the devices tab on the controller. Click "adopt and upgrade".

.. image:: unifi21.png

#. to finish the process issue the `set-inform` command above again. After a few seconds the status on the controller should change to "Upgrading". If not issue the set-inform command again, I used 1-3 times per access-point.

.. image:: unifi22.png

#. after upgrading and rebooting the access-point should be "connected"

.. image:: unifi23.png

#. To enable auto-updating the controller software enter on the CLI where you did `oc login`::

    oc tag --source=docker jacobalberty/unifi:stable aarno-srf2spotify/unifi:latest --scheduled

