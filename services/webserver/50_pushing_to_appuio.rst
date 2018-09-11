Pushing to the APPUiO registry
==============================

In order to be able to push to the APPUiO registry, we will need to configure our APPUiO project and integrate it with our Gitlab repository. This requires some configurative steps using the OpenShift command line interface, which are described in the following sections.


Creating a service account
""""""""""""""""""""""""""

After logging in, our first task is creating login credentials such that Gitlab CI is able to login to the internal APPUiO registry. As we cannot and would not want to use our own login credentials, we will have to create a so called **Service Account (SA)**, which will then have limited permissions and its own credentials.

::

    $ oc create sa gitlab
    serviceaccount "gitlab" created

After the successful creation of the service account we have to grant it permission to push images.

::
    $ oc policy add-role-to-user system:image-pusher system:serviceaccount:docs_example:gitlab
    role "system:image-pusher" added: "system:serviceaccount:docs_example:gitlab"

To find out what credentials we will need to use with the new *gitlab* SA, we use ``oc describe sa gitlab``, which returns a list of secrets that are currently attached to the SA.

.. code-block:: yaml
    :emphasize-lines: 12

    $ oc describe sa gitlab
    Name:           gitlab
    Namespace:      docs_example
    Labels:         <none>

    Mountable secrets:      gitlab-token-jrwqs
                            gitlab-dockercfg-i0efc

    Tokens:                 gitlab-token-c9y0s
                            gitlab-token-jrwqs

    Image pull secrets:     gitlab-dockercfg-i0efc

If we now use ``oc describe secret gitlab-dockercfg-i0efc``, we will find a login token:

.. code-block:: yaml
    :emphasize-lines: 8

    $ oc describe secret gitlab-dockercfg-i0efc
    Name:           gitlab-dockercfg-i0efc
    Namespace:      docs_example
    Labels:         <none>
    Annotations:    kubernetes.io/service-account.name=gitlab
                    kubernetes.io/service-account.uid=f6d0f5b4-f507-11e6-a897-fa163ec9e279
                    openshift.io/token-secret.name=gitlab-token-c9y0s
                    openshift.io/token-secret.value=VERYLONGTOKEN

Using this *VERYLONGTOKEN*, we can now return to Gitlab and configure it such that it can push to the APPUiO registry.


Configuring the Kubernetes Integration
""""""""""""""""""""""""""""""""""""""

To configure the integration, got to your Gitlab repository and choose ``Integrations`` in the upper right settings menu. Once there, click on Kubernetes in the list of integrations and enter the configuration as can be seen in the image below:

.. image:: kubernetes_integration.PNG


Extending .gitlab-ci.yml
""""""""""""""""""""""""

After we have successfully added the Kubernetes integration to our Gitlab repository, we can go on and extend our CI configuration such that it pushes to the APPUiO registry. We will use a custom Gitlab CI runner with installed OpenShift CLI, as we need to interact with the APPUiO API from within our job.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 7, 9, 14-15

    variables:
        OC_REGISTRY_URL: registry.appuio.ch
        OC_REGISTRY_IMAGE: $OC_REGISTRY_URL/$KUBE_NAMESPACE/webserver
        OC_VERSION: 1.4.1
        
    build-staging:
      environment: webserver-staging
      stage: deploy-staging
      image: appuio/gitlab-runner-oc:$OC_VERSION
      services:
        - docker:dind
      script:
        # login to the service account to get access to the internal registry
        - oc login $KUBE_URL --token=$KUBE_TOKEN
        - docker login -u serviceaccount -p `oc whoami -t` $OC_REGISTRY_URL
        # build the docker image and tag it as latest
        # use the current latest image as a caching source
        - docker pull $OC_REGISTRY_IMAGE:latest
        - docker build --cache-from $OC_REGISTRY_IMAGE:latest -t $OC_REGISTRY_IMAGE:latest .
        # push the image to the internal registry
        - docker push $OC_REGISTRY_IMAGE:latest

What happens in this snippet is that we login to APPUiO using the OpenShift CLI, specifying the parameters that we set in the Kubernetes integration as URL and login token. We then login to the internal APPUiO registry with the username ``serviceaccount`` (doesn't matter what your SA is actually called) and a password that we get directly from the OC CLI using ``oc whoami -t``.

Important to know is that Gitlab CI will only inject ``KUBE_URL`` and ``KUBE_TOKEN`` as environment variables if the job is classified as a deployment job (which means that it has to contain an ``environment: xyz`` property). For more information about deployment jobs and variables see #2.

The URL to the registry as well as the name of the image we will be building are specified as CI variables in lines 1-3. The custom runner we introduced in the snippet (``image: appuio/gitlab-runner-oc:1.4.1``) simply extends the official ``docker:latest`` with the OC CLI.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Kubernetes/OpenShift Integration [Gitlab Docs] <https://docs.gitlab.com/ce/user/project/integrations/kubernetes.html>`_
    #. `Deployment Variables [Gitlab Docs] <https://docs.gitlab.com/ce/ci/variables/#deployment-variables>`_
