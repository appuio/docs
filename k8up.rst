K8up (Backup Service)
=====================

.. admonition:: Beta Warning
    :class: note

    This service is in productive use by some of our customers.
    It is still in beta, though. Features may be added or removed.
    We're happy about your feedback!

What is K8up?
-------------

On APPUiO we've made backing up your data simple. All you need to do is
create a backup ``Schedule`` object in your APPUiO namespace. This will
backup the file system data of your PVCs in that namespace.

- Example: `Backup Schedule <https://k8up.io/docs/latest/backup.html>`__ (k8up documentation)

It's that easy. We take care of the rest: Regularly run the backup job and
monitor if and how it is running.

More about K8up
---------------

See the official `K8up documentation <https://k8up.io/>`__.
