# Read Logs

## Pods

To access Pod logs, there are several ways:

* Running Pod: `oc logs <podname>` or via Web Console
* Not running Pod (f.e. failed): `oc logs --previous <podname>`

## Builds

To see build logs, use:

* `oc logs bc/<name>`

## oc logs

`oc logs --help` gives several examples and help for reading log files
