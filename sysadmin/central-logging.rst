Central Logging
===============

.. contents::

Elasticsearch and Fluentd is used to collect logs from Pods and Syslogs.
The official documentation is here: `Aggregating Container Logs
<https://docs.openshift.com/enterprise/latest/install_config/aggregate_logging.html>`__.
Even more detailed documentation can be found in various READMEs on the
corresponding `Github project <https://github.com/openshift/origin-aggregated-logging>`__.

Elasticsearch Security
----------------------

For security measures the plugin `Search Guard <https://github.com/floragunncom/search-guard>`__
is used. It protects Elasticsearch access and does the authentication and authorization.

The configuration found in the Elasticsearch Pod under ``/etc/elasticsearch/elasticsearch.yml``
looks like this: ::

  searchguard:
    config_index_name: ".searchguard.${HOSTNAME}"
    key_path: /elasticsearch/${CLUSTER_NAME}
    allow_all_from_loopback: false
    authentication:
      authentication_backend:
        impl: com.floragunn.searchguard.authentication.backend.simple.AlwaysSucceedAuthenticationBackend
      authorizer:
        impl: com.floragunn.searchguard.authorization.simple.SettingsBasedAuthorizator
      http_authenticator:
        impl: io.fabric8.elasticsearch.plugin.HTTPSProxyClientCertAuthenticator
      proxy:
        header: X-Proxy-Remote-User
        trusted_ips: ["*"]
      authorization:
        settingsdb:
          roles:
            admin: ["admin"]
            fluentd: ["fluentd"]
            kibana: ["kibana"]
    ssl:
      transport:
        http:
          keystore_type: JKS
          keystore_filepath: /etc/elasticsearch/keys/key
          keystore_password: kspass
          enforce_clientauth: true
          truststore_type: JKS
          truststore_filepath: /etc/elasticsearch/keys/truststore
          truststore_password: tspass
    actionrequestfilter:
      names: ["readonly", "fluentd", "kibana", "admin"]
      readonly:
        allowed_actions: ["indices:data/read/*", "*monitor*"]
        forbidden_actions: ["cluster:*", "indices:admin*"]
      fluentd:
        allowed_actions: ["indices:data/write/*", "indices:admin/create"]
      kibana:
       allowed_actions: ["indices:data/read/*", "*monitor*", "indices:admin/read", "indices:admin/mappings/fields/get*"]
  
  openshift:
    acl:
      users:
        names: ["system.logging.fluentd", "system.logging.kibana", "system.logging.curator"]
        system.logging.fluentd:
          execute: ["actionrequestfilter.fluentd"]
          actionrequestfilter.fluentd.comment: "Fluentd can only write"
        system.logging.kibana:
          bypass: ["*"]
          execute: ["actionrequestfilter.kibana"]
          actionrequestfilter.kibana.comment: "Kibana can only read from every other index"
        system.logging.kibana.*.comment: "Kibana can do anything in the kibana index"
        system.logging.kibana.*.indices: [".kibana.*"]
        system.logging.curator:
          execute: ["actionrequestfilter.curator"]
          actionrequestfilter.curator.comment: "Curator can list all indices and delete them"
        system.admin:
          bypass: ["*"]
        system.admin.*.comment: "Admin user can do anything"


Elasticsearch Retention (Curator)
---------------------------------

Detailed documentation is here: `Curator <https://github.com/openshift/origin-aggregated-logging#curator>`__.

Default Curator configuration on APPUiO: ::

  .defaults:
    delete:
      days: 7
    runhour: 0
    runminute: 0


Central logging monitoring
--------------------------

For monitoring and testing the whole logging infrastructure, some scripts are available under
`origin-aggregated-logging/hack/testing <https://github.com/openshift/origin-aggregated-logging/tree/master/hack/testing>`__.
