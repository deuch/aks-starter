# Logging

Logging in a multi-tenant AKS cluster

### Pre-requisites

Create a namespace named fluent-log

Create a Log Analytics Workspace

Create a secret named fluentbit-secrets with 2 keys and the associated values in the fluent-log namespace :

- WorkspaceId
- SharedKey

### How it works

For each pods in namespace app1 and app2, the logs will be sent to the log analytics workspace in 2 different tables CL_app1 and CL_app2

To add a new namespace, you have to modify the configmap (config.yaml) and add the new namespace name for each section :

output.conf
input-kubernetes.conf
filter-kubernetes.conf

