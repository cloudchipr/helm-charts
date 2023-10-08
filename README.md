# C8R-Agent helm chart

## Introduction  

>We are using **Prometheus Node Exporter**, **PrometheusKubeStateMetrucs** and **Grafana Agent** to collect metrics and send to our Instances to calculate the cost.

### Prometheus Community

[![GitHub Prometheus Community](https://img.shields.io/badge/GitHub-Prometheus-red)](https://github.com/prometheus)

### Grafana Labs

[![GitHub Grafana Labs](https://img.shields.io/badge/GitHub-Grafana-orange)](https://github.com/grafana)

## Requirements

* Kubernetes >= 1.19
* Helm >= 3

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

To install the chart:

```bash
helm install c8r-agent -n c8r-agent --create-namespace c8r/c8r-agent
```

To uninstall the chart:

```bash
helm uninstall c8r-agent -n c8r-agent c8r-agent
kubectl delete namespace c8r-agent
```

## Parameters

### Global

| Name                        | Description                                                                                                                      | Value                                         |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `global.image.registry`     | Global image registry to use if it needs to be overriden for some specific use cases (e.g local registries, custom images, ...). | `""`                                          |
| `global.image.pullSecrets`  | Optional set of global image pull secrets.                                                                                       | `[]`                                          |
| `global.podSecurityContext` | Security context to apply to the C8R Grafana Agent pod.                                                                          | `{}`                                          |
| `global.clusterId`          | Your Cluster ID (Requried).                                                                                                      | `""`                                          |
| `global.endpointURL`        | EndpintURL to send metrics.                                                                                                      | `https://metrics.cloudchipr.com/api/v1/write` |
| `global.bearerToken`        | Bearer token for authorization.                                                                                                  | `""`                                          |

### Optional

| Name               | Description                                                                                | Value |
| ------------------ | ------------------------------------------------------------------------------------------ | ----- |
| `nameOverride`     | Overrides the chart's name. Used to change the infix in the resource names.                | `nil` |
| `fullnameOverride` | Overrides the chart's computed fullname. Used to change the full prefix of resource names. | `nil` |
| `initContainers`   | The init containers to run.                                                                | `[]`  |

### Requried

| Name                                          | Description                                                    | Value       |
| --------------------------------------------- | -------------------------------------------------------------- | ----------- |
| `kubeStateMetrics.enabled`                    | Enable Kube-State-Metrics to collect metrics from K8S (State). | `true`      |
| `nodeExporter.enabled`                        | Deploy node exporter as a daemonset to all nodes.              | `true`      |
| `prometheus-node-exporter.service.enabled`    | Enable node-exporter service.                                  | `true`      |
| `prometheus-node-exporter.service.type`       | node-exporter service type.                                    | `ClusterIP` |
| `prometheus-node-exporter.service.port`       | node-exporter service port (not default).                      | `9191`      |
| `prometheus-node-exporter.service.targetPort` | node-exporter target port.                                     | `9191`      |

### Agent

| Name                              | Description                                                                                                            | Value           |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------- |
| `agent.configMap.create`          | Create configMap for agent.                                                                                            | `true`          |
| `agent.configMap.name`            | Name of existing ConfigMap to use. Used when create is false.                                                          | `nil`           |
| `agent.configMap.key`             | Key in ConfigMap to get config from.                                                                                   | `nil`           |
| `agent.resources.requests.cpu`    | Resource requests cpu to apply to the agent container.                                                                 | `100m`          |
| `agent.resources.requests.memory` | Resource requests memory to apply to the agent container.                                                              | `256Mi`         |
| `agent.resources.limits.cpu`      | Resource limits cpu to apply to the agent container.                                                                   | `250m`          |
| `agent.resources.limits.memory`   | Resource limits memory to apply to the agent container.                                                                | `512Mi`         |
| `agent.storagePath`               | Path to where C8R Grafana Agent stores data (for example, the Write-Ahead Log).                                        | `/tmp/agent`    |
| `agent.listenAddr`                | Address to listen for traffic on. 0.0.0.0 exposes the UI to other containers.                                          | `0.0.0.0`       |
| `agent.listenPort`                | Port to listen for traffic on.                                                                                         | `80`            |
| `agent.extraEnv`                  | Extra environment variables to pass to the agent container.                                                            | `[]`            |
| `agent.envFrom`                   | Maps all the keys on a ConfigMap or Secret as environment variables.                                                   | `[]`            |
| `agent.extraArgs`                 | Extra args to pass to `agent run`.                                                                                     | `[]`            |
| `agent.extraPorts`                | Extra ports to expose on the Agent.                                                                                    | `[]`            |
| `agent.mounts.extra`              | Extra volume mounts to add into the C8R Grafana Agent container. Does not affect the watch container.                  | `[]`            |
| `agent.securityContext`           | Security context to apply to the C8R Grafana Agent container.                                                          | `{}`            |
| `image.registry`                  | C8R Grafana Agent image registry (defaults to docker.io).                                                              | `docker.io`     |
| `image.repository`                | C8R Grafana Agent image repository.                                                                                    | `grafana/agent` |
| `image.tag`                       | (string) C8R Grafana Agent image tag. When empty, the Chart's appVersion is used.                                      | `v0.36.2`       |
| `image.digest`                    | C8R Grafana Agent image's SHA256 digest (either in format "sha256:XYZ" or "XYZ"). When set, will override `image.tag`. | `nil`           |
| `image.pullPolicy`                | C8R Grafana Agent image pull policy.                                                                                   | `IfNotPresent`  |
| `image.pullSecrets`               | Optional set of image pull secrets.                                                                                    | `[]`            |
| `rbac.create`                     | Whether to create RBAC resources for the agent.                                                                        | `true`          |
| `serviceAccount.create`           | Whether to create a service account for the C8R Grafana Agent deployment.                                              | `true`          |
| `serviceAccount.annotations`      | Annotations to add to the created service account.                                                                     | `{}`            |
| `serviceAccount.name`             | The name of the existing service account to use when serviceAccount.create is false.                                   | `nil`           |

### ConfigMap Reloader

| Name                                       | Description                                                                                                                                      | Value                         |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------- |
| `configReloader.enabled`                   | Enables automatically reloading when the agent config changes.                                                                                   | `true`                        |
| `configReloader.image.registry`            | Config reloader image registry (defaults to docker.io).                                                                                          | `docker.io`                   |
| `configReloader.image.repository`          | Repository to get config reloader image from.                                                                                                    | `jimmidyson/configmap-reload` |
| `configReloader.image.tag`                 | Tag of image to use for config reloading.                                                                                                        | `v0.8.0`                      |
| `configReloader.image.digest`              | SHA256 digest of image to use for config reloading (either in format "sha256:XYZ" or "XYZ"). When set, will override `configReloader.image.tag`. | `""`                          |
| `configReloader.customArgs`                | Override the args passed to the container.                                                                                                       | `[]`                          |
| `configReloader.resources.requests.cpu`    | Resource requests cpu to apply to the config reloader container.                                                                                 | `10m`                         |
| `configReloader.resources.requests.memory` | Resource requests memory to apply to the config reloader container.                                                                              | `50Mi`                        |
| `configReloader.resources.limits.cpu`      | Resource limits cpu to apply to the config reloader container.                                                                                   | `10m`                         |
| `configReloader.resources.limits.memory`   | Resource limits memory to apply to the config reloader container.                                                                                | `50Mi`                        |
| `configReloader.securityContext`           | Security context to apply to the C8R Grafana configReloader container.                                                                           | `{}`                          |

### Controller

| Name                                                       | Description                                                                                                                                                                                          | Value          |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `controller.replicas`                                      | Number of pods to deploy.                                                                                                                                                                            | `3`            |
| `controller.hostNetwork`                                   | Configures Pods to use the host network. When set to true, the ports that will be used must be specified.                                                                                            | `false`        |
| `controller.hostPID`                                       | Configures Pods to use the host PID namespace.                                                                                                                                                       | `false`        |
| `controller.dnsPolicy`                                     | Configures the DNS policy for the pod.                                                                                                                                                               | `ClusterFirst` |
| `controller.updateStrategy`                                | Update strategy for updating deployed Pods.                                                                                                                                                          | `{}`           |
| `controller.nodeSelector`                                  | nodeSelector to apply to C8R Grafana Agent pods.                                                                                                                                                     | `{}`           |
| `controller.tolerations`                                   | Tolerations to apply to C8R Grafana Agent pods.                                                                                                                                                      | `[]`           |
| `controller.priorityClassName`                             | priorityClassName to apply to C8R Grafana Agent pods.                                                                                                                                                | `""`           |
| `controller.podAnnotations`                                | Extra pod annotations to add.                                                                                                                                                                        | `{}`           |
| `controller.podLabels`                                     | Extra pod labels to add.                                                                                                                                                                             | `{}`           |
| `controller.autoscaling.enabled`                           | Creates a HorizontalPodAutoscaler for controller type deployment.                                                                                                                                    | `false`        |
| `controller.autoscaling.minReplicas`                       | The lower limit for the number of replicas to which the autoscaler can scale down.                                                                                                                   | `1`            |
| `controller.autoscaling.maxReplicas`                       | The upper limit for the number of replicas to which the autoscaler can scale up.                                                                                                                     | `5`            |
| `controller.autoscaling.targetCPUUtilizationPercentage`    | Average CPU utilization across all relevant pods, a percentage of the requested value of the resource for the pods. Setting `targetCPUUtilizationPercentage` to 0 will disable CPU scaling.          | `0`            |
| `controller.autoscaling.targetMemoryUtilizationPercentage` | Average Memory utilization across all relevant pods, a percentage of the requested value of the resource for the pods. Setting `targetMemoryUtilizationPercentage` to 0 will disable Memory scaling. | `80`           |
| `controller.affinity`                                      | Affinity configuration for pods.                                                                                                                                                                     | `{}`           |
| `controller.volumes.extra`                                 | Extra volumes to add to the C8R Grafana Agent pod.                                                                                                                                                   | `[]`           |

### Service

| Name                  | Description                                                | Value       |
| --------------------- | ---------------------------------------------------------- | ----------- |
| `service.enabled`     | service Creates a Service for the controller's pods.       | `true`      |
| `service.type`        | Service type.                                              | `ClusterIP` |
| `service.clusterIP`   | Cluster IP, can be set to None, empty "" or an IP address. | `""`        |
| `service.annotations` | Service annotations.                                       | `{}`        |

## License

[**Apache 2.0 License**](./LICENSE)
