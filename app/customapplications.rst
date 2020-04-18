.. _custom-applications:

Custom Applications
===================

For application development we recommend to set up a complete CI/CD pipeline
with linting, automated tests, automatic image builds and deployment, all
from source code.

Please visit the following sites for working demo setups we have prepared
for your convenience:

- `GitLab.com/appuio <https://gitlab.com/appuio?filter=example>`__
- `Bitbucket.org/appuio <https://bitbucket.org/appuio/?search=example>`__
- `GitHub.com/appuio <https://github.com/appuio?q=example>`__

Alternatively, you may consult the `OpenShift Developer Guide
<https://docs.openshift.com/container-platform/3.11/dev_guide/>`__
on Creating new applications,
which covers several languages, frameworks and strategies.

Logging
-------

Every application should log to stdout. APPUiO will automatically collect
that output and make it accessible via Kibana at `logging.appuio.ch
<https://logging.appuio.ch>`__. See :ref:`application-logs` for more details.

The Kibana user interface allows powerful queries on all captured application
console output (you don't have access to cluster logs for security reasons),
but it requires some data analyst thinking and style of working.

Exception Tracking
------------------

For APM and exception tracking we suggest to use an external service like
`Sentry`_, `New Relic`_ or `Datadog`_. (They all provide an API to automate
configuring your integration, which we highly recommend doing!)
They all allow to configure alerting or integrate with alert services.

.. _Sentry: https://sentry.io/_/resources/customer-success/alert-rules/
.. _New Relic: https://docs.newrelic.com/docs/alerts/new-relic-alerts/getting-started/introduction-new-relic-alerts
.. _Datadog: https://docs.datadoghq.com/monitors/notifications/?tab=is_alert

Monitoring & Alerting
---------------------

From a concept point of view, cloud applications should be *self-healing*
and hence have less need to be monitored for everything. You should specify
`resource requests and limits`_ for your Pods as well as `liveness and
readiness probes`_, then APPUiO can automatically kill and restart your
applications when they start using too much CPU or memory, or are stuck in
a broken state. In addition, we suggest the following options to actively
monitor your application and receive alerts:

- Self-hosted **Prometheus (with AlertManager)**. Please `contact us`_ as we
  need to install Prometheus for you in your namespace. See the Prometheus
  docs on how to configure `alert backends`_ and `alerting rules`_.

- Use your favorite **infrastructure monitoring service** that monitors
  uptime, such as Datadog, New Relic, UptimeRobot and `many more`_.

- With a **Service Level Agreement (SLA)** we monitor your application for you
  24/7, and our engineers get your application running for you again, even on
  holidays and outside office hours. Please `contact us`_ for details.

.. _resource requests and limits:
    https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
.. _liveness and readiness probes:
    https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
.. _Helm chart: https://github.com/helm/charts/tree/master/stable/prometheus
.. _alert backends: https://prometheus.io/docs/alerting/configuration/
.. _alerting rules: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
.. _many more: https://alternativeto.net/software/site24x7/
.. _contact us: https://control.vshn.net
