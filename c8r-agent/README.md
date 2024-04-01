# Cloudchipr SaaS Platform C8R-Agent For Metrics

This chart deploys Cloudchipr Platform c8r-agent to your local cluster

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)


## Requirements

* Kubernetes >= [1.19](https://kubernetes.io/releases/)
* Helm >= [3](https://github.com/helm/helm/releases)

## Installation

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add c8r https://cloudchipr.github.io/helm-charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
c8r` to see the charts.
the latest versions of the packages.

## How to install

Run the following command to install the chart

```bash
helm upgrade -i c8r-agent -n c8r-agent c8r/c8r-agent \
  --set cluster_id="YOUR_CLUSTER_ID" \ 
  --set c8r_token="YOUR_API_TOKEN"
  --create-namespace
```

To uninstall the chart:

```bash
helm uninstall c8r-agent -n c8r-agent
kubectl delete namespace c8r-opencost
```

## Parameters

### General Configuration

| Name                | Description                                                                   | Value                        |
| ------------------- | ----------------------------------------------------------------------------- | ---------------------------- |
| `namespaceOverride` | Overrides the default namespace where the chart will be installed (Optional). | `""`                         |
| `replicaCount`      | Number of replicas for the deployment.                                        | `1`                          |
| `imagePullPolicy`   | Image pull policy (Always, IfNotPresent, Never).                              | `Always`                     |
| `imageRegistry`     | Default registry for all images (Optional).                                   | `""`                         |
| `cluster_id`        | Identifier for cluster. (Required).                                           | ``                           |
| `c8r_token`         | Token to authenticate with C8R API. (Required).                               | ``                           |

### RBAC Configuration

| Name                  | Description                                                                                                                                                                  | Value  |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| `rbac.create`         | If true, create & use RBAC resources                                                                                                                                         | `true` |
| `rbac.useClusterRole` | If set to false - Run without Cluteradmin privs needed - ONLY works if namespace is also set (if useExistingRole is set this name is used as ClusterRole or Role to bind to) | `true` |
| `rbac.extraRules`     | Add permissions for CustomResources' apiGroups in Role/ClusterRole. Should be used in conjunction with Custom Resource State Metrics configuration                           | `[]`   |

### Service Account Configuration

| Name                              | Description                                                             | Value  |
| --------------------------------- | ----------------------------------------------------------------------- | ------ |
| `serviceAccount.create`           | Specifies whether a ServiceAccount should be created, require rbac true | `true` |
| `serviceAccount.name`             | The name of the ServiceAccount to use.                                  | `nil`  |
| `serviceAccount.imagePullSecrets` | Reference to one or more secrets to be used when pulling images         | `[]`   |
| `serviceAccount.annotations`      | ServiceAccount annotations.                                             | `{}`   |

### Deployment Configuration

| Name                      | Description                                         | Value |
| ------------------------- | --------------------------------------------------- | ----- |
| `deployment.labels`       | Extra labels for the service.                       | `{}`  |
| `deployment.annotations`  | Annotations for the service.                        | `{}`  |
| `deployment.nodeSelector` | Node Selector labels for pod assignment (Optional). | `{}`  |
| `deployment.affinity`     | Affinity settings for pod assignment (Optional).    | `{}`  |
| `deployment.tolerations`  | Tolerations for pod assignment (Optional).          | `[]`  |

### Prometheus Container Configuration

| Name                                                  | Description                                           | Value  |
| ----------------------------------------------------- | ----------------------------------------------------- | ------ |
| `deployment.c8rPrometheuServer.name`                  | Container name for the Opencost component (Optional). | `""`   |
| `deployment.c8rPrometheuServer.image`                 | Docker image for the Opencost.                        | `""`   |
| `deployment.c8rPrometheuServer.tag`                   | Docker image tag for the Opencost.                    | `""`   |
| `deployment.c8rPrometheuServer.command`               | Command for Opencost container.                       | `[]`   |
| `deployment.c8rPrometheuServer.args`                  | Args for Opencost container.                          | `[]`   |
| `deployment.c8rPrometheuServer.resources`             | CPU/Memory resource requests/limits.                  | `{}`   |
| `deployment.c8rPrometheuServer.probes.enabled`        | Enable/Disable Probes for pod.                        | `true` |
| `deployment.c8rPrometheuServer.probes.readinessProbe` | Custom readiness probe configuration.                 | `{}`   |
| `deployment.c8rPrometheuServer.probes.livenessProbe`  | Custom liveness probe configuration.                  | `{}`   |
| `deployment.c8rPrometheuServer.probes.startupProbe`   | Custom startup probe configuration.                   | `{}`   |

### Kube-State-Metrics Container Configuration

| Name                                                   | Description                                                     | Value                                   |
| ------------------------------------------------------ | --------------------------------------------------------------- | --------------------------------------- |
| `deployment.c8rKubeStateMetrics.name`                  | Container name for the kube-state-metrics component (Optional). | `""`                                    |
| `deployment.c8rKubeStateMetrics.image`                 | Docker image for the proxy.                                     | `kube-state-metrics/kube-state-metrics` |
| `deployment.c8rKubeStateMetrics.tag`                   | Docker image tag for the proxy.                                 | `v2.10.0`                               |
| `deployment.c8rKubeStateMetrics.command`               | Command for Opencost container.                                 | `[]`                                    |
| `deployment.c8rKubeStateMetrics.args`                  | Args for Opencost container.                                    | `[]`                                    |
| `deployment.c8rKubeStateMetrics.probes.enabled`        | Enable/Disable Probes for pod.                                  | `true`                                  |
| `deployment.c8rKubeStateMetrics.probes.readinessProbe` | Custom readiness probe configuration.                           | `{}`                                    |
| `deployment.c8rKubeStateMetrics.probes.livenessProbe`  | Custom liveness probe configuration.                            | `{}`                                    |
| `deployment.c8rKubeStateMetrics.probes.startupProbe`   | Custom startup probe configuration.                             | `{}`                                    |

### Open Cost Container Configuration

| Name                                           | Description                                            | Value  |
| ---------------------------------------------- | ------------------------------------------------------ | ------ |
| `deployment.c8rOpenCost.name`                  | Deployment name for the OpenCost component (Optional). | `""`   |
| `deployment.c8rOpenCost.image`                 | Docker image for the OpenCost.                         | `""`   |
| `deployment.c8rOpenCost.tag`                   | Docker image tag for the OpenCost.                     | `""`   |
| `deployment.c8rOpenCost.command`               | Command for Opencost container.                        | `[]`   |
| `deployment.c8rOpenCost.args`                  | Args for Opencost container.                           | `[]`   |
| `deployment.c8rOpenCost.resources`             | CPU/Memory resource requests/limits.                   | `{}`   |
| `deployment.c8rOpenCost.probes.enabled`        | Enable/Disable Probes for pod.                         | `true` |
| `deployment.c8rOpenCost.probes.readinessProbe` | Custom readiness probe configuration.                  | `{}`   |
| `deployment.c8rOpenCost.probes.livenessProbe`  | Custom liveness probe configuration.                   | `{}`   |
| `deployment.c8rOpenCost.probes.startupProbe`   | Custom startup probe configuration.                    | `{}`   |

### C8R Agent Configuration

| Name                                        | Description                                             | Value  |
| ------------------------------------------- | ------------------------------------------------------- | ------ |
| `deployment.c8rAgent.name`                  | Deployment name for the C8R Agent component (Optional). | `""`   |
| `deployment.c8rAgent.image`                 | Docker image for the C8R Agent                          | `""`   |
| `deployment.c8rAgent.tag`                   | Docker image tag for the OpenCost.                      | `""`   |
| `deployment.c8rAgent.command`               | Command for C8R Agent container.                        | `[]`   |
| `deployment.c8rAgent.args`                  | Args for C8R Agent container.                           | `[]`   |
| `deployment.c8rAgent.resources`             | CPU/Memory resource requests/limits.                    | `{}`   |
| `deployment.c8rAgent.probes.enabled`        | Enable/Disable Probes for pod.                          | `true` |
| `deployment.c8rAgent.probes.readinessProbe` | Custom readiness probe configuration.                   | `{}`   |
| `deployment.c8rAgent.probes.livenessProbe`  | Custom liveness probe configuration.                    | `{}`   |
| `deployment.c8rAgent.probes.startupProbe`   | Custom startup probe configuration.                     | `{}`   |

