Pushing to the APPUiO registry
==============================

In order to be able to push to the APPUiO registry, we will need to configure
our APPUiO project and integrate it with our GitLab repository. This requires
some configurative steps using the OpenShift command line interface, which
are described in the following sections.

Creating a service account
""""""""""""""""""""""""""

After logging in, our first task is creating login credentials such that
GitLab CI is able to login to the internal APPUiO registry. As we cannot and
would not want to use our own login credentials, we will have to create a so
called **Service Account (SA)**, which will then have limited permissions and
its own credentials.

.. code-block:: console

  $ oc create sa gitlab
  serviceaccount "gitlab" created

After the successful creation of the service account we have to grant it
permission to push images.

.. code-block:: console

  $ oc policy add-role-to-user system:image-pusher system:serviceaccount:docs_example:gitlab
  role "system:image-pusher" added: "system:serviceaccount:docs_example:gitlab"

To retrieve the login token for the created service account, we can use
``oc sa get-token gitlab``. Using this token, we can now return to GitLab and
configure it such that it can push to the APPUiO registry.

Configuring the Kubernetes Integration (optional)
"""""""""""""""""""""""""""""""""""""""""""""""""

To configure the integration, go to your GitLab repository and choose
``Integrations`` in the upper right settings menu. Once there, click on Kubernetes
in the list of integrations and enter the configuration as can be seen in the
image below:

.. image:: kubernetes_integration.PNG

Extending .gitlab-ci.yml
""""""""""""""""""""""""

After we have successfully added the Kubernetes integration to our GitLab
repository, we can go on and extend our CI configuration such that it pushes
to the APPUiO registry. We will use a custom GitLab CI runner with installed
OpenShift CLI, as we need to interact with the APPUiO API from within our job.

.. code-block:: yaml
    :caption: .gitlab-ci.yml
    :linenos:
    :emphasize-lines: 7, 9, 14-15

    variables:
        OC_REGISTRY_URL: registry.appuio.ch
        OC_REGISTRY_IMAGE: $OC_REGISTRY_URL/$KUBE_NAMESPACE/webserver
        OC_VERSION: 3.11.0

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

What happens in this snippet is that we login to APPUiO using the OpenShift CLI,
specifying the parameters that we set in the Kubernetes integration as URL and
login token. We then login to the internal APPUiO registry with the username
``serviceaccount`` (doesn't matter what your SA is actually called) and a password
that we get directly from the OC CLI using ``oc whoami -t``.

Important to know is that GitLab CI will only inject ``KUBE_URL`` and ``KUBE_TOKEN``
as environment variables if the job is classified as a deployment job (which means
that it has to contain an ``environment: xyz`` property). For more information
about deployment jobs and variables see #2.

The URL to the registry as well as the name of the image we will be building are
specified as CI variables in lines 1-3. The custom runner we introduced in the
snippet (``image: appuio/gitlab-runner-oc:3.11.0``) simply extends the official
``docker:latest`` with the OC CLI.

.. admonition:: Relevant Readings / Resources
    :class: note

    #. `Kubernetes/OpenShift Integration [GitLab Docs] <https://docs.gitlab.com/ce/user/project/integrations/kubernetes.html>`_
    #. `Deployment Variables [GitLab Docs] <https://docs.gitlab.com/ce/ci/variables/#deployment-variables>`_
