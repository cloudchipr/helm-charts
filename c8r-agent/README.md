# Cloudchipr SaaS Platform C8R-Agent For Metrics

## This is a Beta feature and has not been officially released yet

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
  --set c8r_api_key="YOUR_API_TOKEN"
  --create-namespace
```

To uninstall the chart:

```bash
helm uninstall c8r-agent -n c8r-agent
kubectl delete namespace c8r-opencost
```

## Parameters

### General Configuration

| Name                         | Description                                                                   | Value          |
| ---------------------------- | ----------------------------------------------------------------------------- | -------------- |
| `namespaceOverride`          | Overrides the default namespace where the chart will be installed (Optional). | `""`           |
| `replicaCount`               | Number of replicas for the deployment.                                        | `1`            |
| `imagePullPolicy`            | Image pull policy (Always, IfNotPresent, Never).                              | `Always`       |
| `imageRegistry`              | Default registry for all images (Optional).                                   | `""`           |
| `serviceAccount.name`        | service account name to create                                                | `c8r-agent-sa` |
| `serviceAccount.labels`      | service account labels                                                        | `{}`           |
| `serviceAccount.annotations` | service account annotations                                                   | `{}`           |
| `c8r_api_key`                | Token to authenticate with C8R API. (Required).                               | `""`           |

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

| Name                               | Description                                            | Value |
| ---------------------------------- | ------------------------------------------------------ | ----- |
| `deployment.c8rOpenCost.name`      | Deployment name for the OpenCost component (Optional). | `""`  |
| `deployment.c8rOpenCost.image`     | Docker image for the OpenCost.                         | `""`  |
| `deployment.c8rOpenCost.tag`       | Docker image tag for the OpenCost.                     | `""`  |
| `deployment.c8rOpenCost.command`   | Command for Opencost container.                        | `[]`  |
| `deployment.c8rOpenCost.args`      | Args for Opencost container.                           | `[]`  |
| `deployment.c8rOpenCost.resources` | CPU/Memory resource requests/limits.                   | `{}`  |
| `deployment.c8rOpenCost.env`       | Environment variables for the OpenCost container.      | `{}`  |

### C8R Agent Configuration

| Name                            | Description                                             | Value |
| ------------------------------- | ------------------------------------------------------- | ----- |
| `deployment.c8rAgent.name`      | Deployment name for the C8R Agent component (Optional). | `""`  |
| `deployment.c8rAgent.image`     | Docker image for the C8R Agent                          | `""`  |
| `deployment.c8rAgent.tag`       | Docker image tag for the OpenCost.                      | `""`  |
| `deployment.c8rAgent.command`   | Command for C8R Agent container.                        | `[]`  |
| `deployment.c8rAgent.args`      | Args for C8R Agent container.                           | `[]`  |
| `deployment.c8rAgent.resources` | CPU/Memory resource requests/limits.                    | `{}`  |
| `deployment.c8rAgent.env`       | Environment variables for the C8R Agent container.      | `{}`  |

### node-exporter Configuration

| Name                       | Description                                                           | Value  |
| -------------------------- | --------------------------------------------------------------------- | ------ |
| `nodeexporter.create`      | Deploy Node Exporter as a dependency.                                 | `true` |
| `nodeexporter.useExisting` | Node Exporter service name and namespace to use when create is false. | `{}`   |

### dcgm-exporter Configuration

| Name                       | Description                                                                 | Value  |
| -------------------------- | --------------------------------------------------------------------------- | ------ |
| `dcgmexporter.create`      | Deploy Nvidia GPU Exporter as a dependency.                                 | `true` |
| `dcgmexporter.useExisting` | Nvidia GPU Exporter service name and namespace to use when create is false. | `{}`   |
