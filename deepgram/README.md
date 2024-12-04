# Deepgram self-hosted helm chart

This chart deploys the self-hosted version of [Deepgram](https://deepgram.com/), managed by [Cloudchipr](https://www.Cloudchipr.com/), to your Kubernetes cluster.

## Requirements

* [Kubernetes](https://kubernetes.io/) >= 1.19
* [Helm](https://helm.sh/) >= 3

## Using the Cloudchipr Helm Repository

Add the Cloudchipr repository to Helm:

```bash
helm repo add c8r https://Cloudchipr.github.io/helm-charts
helm repo update
```

## Quick start

To install the Helm chart, you need to set up the [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) driver in your Kubernetes cluster to allow mounting a bucket as storage. Alternatively, for testing purposes, you can disable persistence by modifying the `values.yaml` file.

### Install the chart

Follow these steps to install the Helm chart using your `override.yaml` file:

- Create an `override.yaml` file and configure all the necessary fields.

- Run the following command to install the chart in your Kubernetes cluster:

```bash
helm upgrade -i  <example-name> -n <example-namespace> c8r/deepgram -f override.yaml
```

#### Example of `override.yaml` file

This example demonstrates how to configure Deepgram with Google Cloud Storage (GCS) using the FUSE driver.

```yaml
licenseProxy:
  imageRegistry: <your-image-registry>
  imageRepository: <your-license-proxy-image-repo>
  imageTag: &tag "<your-license-proxy-image-tag>"
  replicaCount: 1
  labels:
    environment: dev
  nodeSelector:
    role: deepgram-license-proxy
  resources:
    limits:
      cpu: "1000m"
      memory: 1Gi
      ephemeral-storage: 1Gi
    requests:
      cpu: "100m"
      memory: 512Mi
  envFrom:
    - secretRef:
        name: <your-deepgram-api-key-secret>

api:
  imageRegistry: <your-image-registry>
  imageRepository: <your-api-image-repo>
  imageTag: *tag
  replicaCount: 1
  labels:
    environment: dev
  resources:
    limits:
      cpu: "2"
      memory: 4Gi
      ephemeral-storage: 1Gi
    requests:
      cpu: "1"
      memory: 1Gi
      ephemeral-storage: 1Gi
  nodeSelector:
    role: deepgram-engine-api
  podAnnotations:
    gke-gcsfuse/volumes: "true"
  automountServiceAccountToken: true
  service:
    name: "deepgram"
    labels:
      app: deepgram-dev-engine-api
    type: LoadBalancer
    loadBalancerIP: ""
    externalTrafficPolicy: Local
    internalTrafficPolicy: Local
  envFrom:
    - secretRef:
        name: <your-deepgram-api-key-secret>

engine:
  mode: "sidecar"
  imageRegistry: <your-image-registry>
  imageRepository: <your-engine-image-repo>
  imageTag: *tag
  resources:
    limits:
      cpu: "4"
      memory: 24Gi
      nvidia.com/gpu: "2"
      ephemeral-storage: 1Gi
    requests:
      cpu: "2"
      memory: 10Gi
      nvidia.com/gpu: "2"
      ephemeral-storage: 1Gi
  envFrom:
    - secretRef:
        name: <your-deepgram-api-key-secret>

serviceAccount:
  create: true
  name: "deepgram-sa"
  automountServiceAccountToken: true

persistence:
  enabled: true
  name: "deepgram-dev-models"
  driver: "gcsfuse.csi.storage.gke.io"
  volumeHandle: "<bucket-name>"  # Replace with your bucket name
  storageClassName: "gcs"
  accessModes:
    - ReadWriteMany
  size: "100Gi"

externalSecrets:
  create: true
  apiVersion: "external-secrets.io/v1beta1"
  name: <your-external-secret-name>
  spec:
    refreshInterval: "15s"
    secretStoreRef:
      name: saas-secrets-gke
      kind: ClusterSecretStore
    target:
      name: <your-deepgram-api-key-secret>
    dataFrom:
      - extract:
          key: kv-dev/sources/deepgram/dg-self-hosted-api-key

serviceMonitor:
  enabled: true
  labels:
    release: prometheus-stack
  matchLabels:
    app: deepgram-dev-engine-api
  namespaceSelector: "deepgram"
  port: "engine-metrics"
  path: "/metrics"
  honorLabels: true
  interval: "15s"
```

#### Notes

1. Volume Handle:

  - The `volumeHandle` in the `persistence` section should be your bucket name (e.g., `my-deepgram-bucket`).
  - This chart allows you to use buckets as storage through the FUSE driver.

2. License Proxy Requires Deepgram API Key:

  - You must provide the API key for the license proxy. This can be done by:
    - Creating an ExternalSecret to dynamically pull the key.
    - Using a Kubernetes secret referenced via `envFrom`.

3. Image Configuration:

  - Update the `imageRegistry`, `imageRepository`, and `imageTag` fields to point to your custom container images.
  - If using official Deepgram images, configure `imagePullSecrets` to authenticate with the container registry:

```yaml
imagePullSecrets:
  - name: <your-image-pull-secret>
```

4. Persistence:

  - Set up the FUSE driver to enable bucket mounting.
  - For Google Cloud Storage, the driver is `gcsfuse.csi.storage.gke.io`.

5. Testing Without Persistence:

 - For testing, disable persistence by setting `persistence.enabled` to `false` in `override.yaml`.


## Parameters

### License Proxy Configuration

| Name                                        | Description                                                                  | Value   |
| ------------------------------------------- | ---------------------------------------------------------------------------- | ------- |
| `licenseProxy.imageRegistry`                | Image registry for the License Proxy.                                        | `""`    |
| `licenseProxy.imageRepository`              | Image repository for the License Proxy.                                      | `""`    |
| `licenseProxy.imageTag`                     | Image tag for the License Proxy.                                             | `""`    |
| `licenseProxy.name`                         | Name of the License Proxy deployment.                                        | `""`    |
| `licenseProxy.labels`                       | Labels for the License Proxy pods.                                           | `{}`    |
| `licenseProxy.annotations`                  | Annotations for the License Proxy pods.                                      | `{}`    |
| `licenseProxy.replicaCount`                 | Number of replicas for the License Proxy.                                    | `""`    |
| `licenseProxy.podAnnotations`               | Annotations for the License Proxy pod.                                       | `{}`    |
| `licenseProxy.automountServiceAccountToken` | Boolean indicating whether to auto-mount the service account token.          | `false` |
| `licenseProxy.podSecurityContext`           | Security context for the License Proxy pod.                                  | `{}`    |
| `licenseProxy.serviceAccountName`           | Name of the service account used by License Proxy.                           | `""`    |
| `licenseProxy.nodeSelector`                 | Node selector for License Proxy pods.                                        | `{}`    |
| `licenseProxy.affinity`                     | Affinity rules for License Proxy pods.                                       | `{}`    |
| `licenseProxy.tolerations`                  | Tolerations for License Proxy pods.                                          | `[]`    |
| `licenseProxy.command`                      | Command to override the License Proxy container's default entrypoint.        | `[]`    |
| `licenseProxy.args`                         | Arguments to pass to the License Proxy container.                            | `[]`    |
| `licenseProxy.readinessProbe`               | Readiness probe configuration.                                               | `{}`    |
| `licenseProxy.livenessProbe`                | Liveness probe configuration.                                                | `{}`    |
| `licenseProxy.containerSecurityContext`     | Security context for License Proxy containers.                               | `{}`    |
| `licenseProxy.serverPort`                   | Port for serving traffic.                                                    | `""`    |
| `licenseProxy.statusPort`                   | Port for serving status.                                                     | `""`    |
| `licenseProxy.host`                         | Host name for the License Proxy.                                             | `""`    |
| `licenseProxy.baseUrl`                      | Base URL for accessing the License Proxy.                                    | `""`    |
| `licenseProxy.env`                          | Environment variables for the License Proxy.                                 | `[]`    |
| `licenseProxy.envFrom`                      | Environment variables from external sources.                                 | `[]`    |
| `licenseProxy.resources`                    | Resource limits and requests for License Proxy pods.                         | `{}`    |
| `licenseProxy.containerLifeCycle`           | Configuration for container lifecycle hooks, such as post-start or pre-stop. | `{}`    |

### License Proxy Service Configuration

| Name                                         | Description                                        | Value |
| -------------------------------------------- | -------------------------------------------------- | ----- |
| `licenseProxy.service.name`                  | Name of the License Proxy service.                 | `""`  |
| `licenseProxy.service.labels`                | Labels for the License Proxy service.              | `{}`  |
| `licenseProxy.service.annotations`           | Annotations for the License Proxy service.         | `{}`  |
| `licenseProxy.service.serverPort`            | Server port for License Proxy service.             | `""`  |
| `licenseProxy.service.statusPort`            | Status port for License Proxy service.             | `""`  |
| `licenseProxy.service.type`                  | Type of service to create.                         | `""`  |
| `licenseProxy.service.loadBalancerIP`        | Static IP for LoadBalancer, if applicable.         | `""`  |
| `licenseProxy.service.externalTrafficPolicy` | External traffic policy for License Proxy service. | `""`  |
| `licenseProxy.service.internalTrafficPolicy` | Internal traffic policy for License Proxy service. | `""`  |

### API Configuration

| Name                               | Description                                                                  | Value   |
| ---------------------------------- | ---------------------------------------------------------------------------- | ------- |
| `api.imageRegistry`                | Image registry for the API.                                                  | `""`    |
| `api.imageRepository`              | Image repository for the API.                                                | `""`    |
| `api.imageTag`                     | Image tag for the API.                                                       | `""`    |
| `api.name`                         | Name of the API deployment.                                                  | `""`    |
| `api.labels`                       | Labels for the API pods.                                                     | `{}`    |
| `api.annotations`                  | Annotations for the API pods.                                                | `{}`    |
| `api.replicaCount`                 | Number of replicas for the API.                                              | `""`    |
| `api.podAnnotations`               | Annotations for the API pod.                                                 | `{}`    |
| `api.automountServiceAccountToken` | Boolean indicating whether to auto-mount the service account token.          | `false` |
| `api.podSecurityContext`           | Security context for the API pod.                                            | `{}`    |
| `api.serviceAccountName`           | Name of the service account used by the API.                                 | `""`    |
| `api.nodeSelector`                 | Node selector for API pods.                                                  | `{}`    |
| `api.affinity`                     | Affinity rules for API pods.                                                 | `{}`    |
| `api.tolerations`                  | Tolerations for API pods.                                                    | `[]`    |
| `api.command`                      | Command to override the API container's default entrypoint.                  | `[]`    |
| `api.args`                         | Arguments to pass to the API container.                                      | `[]`    |
| `api.readinessProbe`               | Readiness probe configuration.                                               | `{}`    |
| `api.livenessProbe`                | Liveness probe configuration.                                                | `{}`    |
| `api.containerSecurityContext`     | Security context for API containers.                                         | `{}`    |
| `api.serverPort`                   | Port for serving traffic.                                                    | `""`    |
| `api.env`                          | Environment variables for the API.                                           | `[]`    |
| `api.envFrom`                      | Environment variables from external sources.                                 | `[]`    |
| `api.resources`                    | Resource limits and requests for API pods.                                   | `{}`    |
| `api.containerLifeCycle`           | Configuration for container lifecycle hooks, such as post-start or pre-stop. | `{}`    |

### API Configuration Details

| Name                                                | Description                                 | Value        |
| --------------------------------------------------- | ------------------------------------------- | ------------ |
| `api.config.server.base_url`                        | Base URL for API server.                    | `/v1`        |
| `api.config.server.host`                            | Host for the API server.                    | `0.0.0.0`    |
| `api.config.server.port`                            | Port for the API server.                    | `""`         |
| `api.config.server.callback_conn_timeout`           | Connection timeout for API callbacks.       | `1s`         |
| `api.config.server.callback_timeout`                | Timeout for API callbacks.                  | `10s`        |
| `api.config.server.fetch_conn_timeout`              | Connection timeout for fetching data.       | `1s`         |
| `api.config.server.fetch_timeout`                   | Timeout for fetching data.                  | `60s`        |
| `api.config.resolver`                               | Resolver configuration settings.            | `{}`         |
| `api.config.features.topic_detection`               | Enable or disable topic detection feature.  | `true`       |
| `api.config.features.summarization`                 | Enable or disable summarization feature.    | `true`       |
| `api.config.features.entity_detection`              | Enable or disable entity detection feature. | `false`      |
| `api.config.features.entity_redaction`              | Enable or disable entity redaction feature. | `false`      |
| `api.config.features.speak_streaming`               | Enable or disable speak streaming feature.  | `true`       |
| `api.config.driver_pool.standard.timeout_backoff`   | Backoff factor for timeouts in seconds.     | `1.2`        |
| `api.config.driver_pool.standard.retry_sleep`       | Sleep duration between retries in seconds.  | `2s`         |
| `api.config.driver_pool.standard.retry_backoff`     | Backoff factor for retries.                 | `1.6`        |
| `api.config.driver_pool.standard.max_response_size` | Maximum response size in bytes.             | `1073741824` |

### API Service Configuration

| Name                                | Description                                | Value |
| ----------------------------------- | ------------------------------------------ | ----- |
| `api.service.name`                  | Name of the API service.                   | `""`  |
| `api.service.labels`                | Labels for the API service.                | `{}`  |
| `api.service.annotations`           | Annotations for the API service.           | `{}`  |
| `api.service.serverPort`            | Server port for API service.               | `""`  |
| `api.service.statusPort`            | Status port for API service.               | `""`  |
| `api.service.type`                  | Type of service to create.                 | `""`  |
| `api.service.loadBalancerIP`        | Static IP for LoadBalancer, if applicable. | `""`  |
| `api.service.externalTrafficPolicy` | External traffic policy for API service.   | `""`  |
| `api.service.internalTrafficPolicy` | Internal traffic policy for API service.   | `""`  |

### Engine Configuration

| Name                                  | Description                                                                      | Value        |
| ------------------------------------- | -------------------------------------------------------------------------------- | ------------ |
| `engine.mode`                         | Deployment mode for the Engine.                                                  | `deployment` |
| `engine.imageRegistry`                | Image registry for the Engine.                                                   | `""`         |
| `engine.imageRepository`              | Image repository for the Engine.                                                 | `""`         |
| `engine.imageTag`                     | Image tag for the Engine.                                                        | `""`         |
| `engine.name`                         | Name of the Engine deployment. Will be ignored if mode=sidecar.                  | `""`         |
| `engine.labels`                       | Labels for the Engine pods. Will be ignored if mode=sidecar.                     | `{}`         |
| `engine.annotations`                  | Annotations for the Engine pods. Will be ignored if mode=sidecar.                | `{}`         |
| `engine.replicaCount`                 | Number of replicas for the Engine. Will be ignored if mode=sidecar.              | `""`         |
| `engine.podAnnotations`               | Annotations for the Engine pod. Will be ignored if mode=sidecar.                 | `{}`         |
| `engine.automountServiceAccountToken` | Boolean indicating whether to auto-mount the service account token.              | `false`      |
| `engine.podSecurityContext`           | Security context for the Engine pod. Will be ignored if mode=sidecar.            | `{}`         |
| `engine.serviceAccountName`           | Name of the service account used by the Engine. Will be ignored if mode=sidecar. | `""`         |
| `engine.nodeSelector`                 | Node selector for Engine pods. Will be ignored if mode=sidecar.                  | `{}`         |
| `engine.affinity`                     | Affinity rules for Engine pods. Will be ignored if mode=sidecar.                 | `{}`         |
| `engine.tolerations`                  | Tolerations for Engine pods. Will be ignored if mode=sidecar.                    | `[]`         |
| `engine.command`                      | Command to override the Engine container's default entrypoint.                   | `[]`         |
| `engine.args`                         | Arguments to pass to the Engine container.                                       | `[]`         |
| `engine.startupProbe`                 | Startup probe configuration.                                                     | `{}`         |
| `engine.readinessProbe`               | Readiness probe configuration.                                                   | `{}`         |
| `engine.livenessProbe`                | Liveness probe configuration.                                                    | `{}`         |
| `engine.containerSecurityContext`     | Security context for Engine containers.                                          | `{}`         |
| `engine.serverPort`                   | Port for serving traffic.                                                        | `""`         |
| `engine.metricsPort`                  | Port for serving metrics.                                                        | `""`         |
| `engine.env`                          | Environment variables for the Engine.                                            | `[]`         |
| `engine.envFrom`                      | Environment variables from external sources.                                     | `[]`         |
| `engine.resources`                    | Resource limits and requests for Engine pods.                                    | `{}`         |
| `engine.containerLifeCycle`           | Configuration for container lifecycle hooks, such as post-start or pre-stop.     | `{}`         |

### Engine Configuration Details

| Name                                            | Description                                              | Value     |
| ----------------------------------------------- | -------------------------------------------------------- | --------- |
| `engine.config.server.host`                     | Host for the Engine server.                              | `0.0.0.0` |
| `engine.config.server.port`                     | Port for the Engine server.                              | `""`      |
| `engine.config.server.max_active_requests`      | Maximum number of active requests for the Engine server. | `""`      |
| `engine.config.metrics_server.host`             | Host for the metrics server.                             | `0.0.0.0` |
| `engine.config.metrics_server.port`             | Port for the metrics server.                             | `""`      |
| `engine.config.model_manager.search_paths`      | List of search paths for models.                         | `nil`     |
| `engine.config.features.multichannel`           | Enable or disable multichannel feature.                  | `true`    |
| `engine.config.features.language_detection`     | Enable or disable language detection feature.            | `true`    |
| `engine.config.chunking_batch.min_duration`     | Minimum duration for batch chunking.                     | `""`      |
| `engine.config.chunking_batch.max_duration`     | Maximum duration for batch chunking.                     | `""`      |
| `engine.config.chunking_streaming.min_duration` | Minimum duration for streaming chunking.                 | `""`      |
| `engine.config.chunking_streaming.max_duration` | Maximum duration for streaming chunking.                 | `""`      |
| `engine.config.chunking_streaming.step`         | Step size for streaming chunking.                        | `""`      |
| `engine.config.half_precision.state`            | State for half precision mode.                           | `auto`    |

### Engine Service Configuration

| Name                                   | Description                                                                  | Value |
| -------------------------------------- | ---------------------------------------------------------------------------- | ----- |
| `engine.service.name`                  | Name of the Engine service. Will be ignored if mode=sidecar.                 | `""`  |
| `engine.service.labels`                | Labels for the Engine service. Will be ignored if mode=sidecar.              | `{}`  |
| `engine.service.annotations`           | Annotations for the Engine service. Will be ignored if mode=sidecar.         | `{}`  |
| `engine.service.serverPort`            | Server port for Engine service. Will be ignored if mode=sidecar.             | `""`  |
| `engine.service.statusPort`            | Status port for Engine service. Will be ignored if mode=sidecar.             | `""`  |
| `engine.service.type`                  | Type of service to create. Will be ignored if mode=sidecar.                  | `""`  |
| `engine.service.loadBalancerIP`        | Static IP for LoadBalancer, if applicable. Will be ignored if mode=sidecar.  | `""`  |
| `engine.service.externalTrafficPolicy` | External traffic policy for Engine service. Will be ignored if mode=sidecar. | `""`  |
| `engine.service.internalTrafficPolicy` | Internal traffic policy for Engine service. Will be ignored if mode=sidecar. | `""`  |

### Service Account Configuration

| Name                                          | Description                                                         | Value   |
| --------------------------------------------- | ------------------------------------------------------------------- | ------- |
| `serviceAccount.create`                       | Boolean indicating whether to create a new service account.         | `false` |
| `serviceAccount.name`                         | Name of the service account.                                        | `""`    |
| `serviceAccount.useExisting`                  | Name of an existing service account to use.                         | `""`    |
| `serviceAccount.labels`                       | Labels for the service account.                                     | `{}`    |
| `serviceAccount.annotations`                  | Annotations for the service account.                                | `{}`    |
| `serviceAccount.automountServiceAccountToken` | Boolean indicating whether to auto-mount the service account token. | `true`  |

### Persistence Configuration

| Name                            | Description                                        | Value                        |
| ------------------------------- | -------------------------------------------------- | ---------------------------- |
| `persistance.enabled`           | Boolean indicating whether persistence is enabled. | `true`                       |
| `persistance.name`              | Name of the persistent volume.                     | `""`                         |
| `persistance.driver`            | Name of the storage driver.                        | `gcsfuse.csi.storage.gke.io` |
| `persistance.volumeHandle`      | Identifier for the volume.                         | `""`                         |
| `persistance.storageClassName`  | Name of the storage class for the volume.          | `gcs`                        |
| `persistance.existingClaimName` | Name of an existing volume claim to use.           | `""`                         |
| `persistance.accessModes`       | Access modes for the persistent volume.            | `["ReadWriteMany"]`          |
| `persistance.size`              | Requested size for the persistent volume.          | `100Gi`                      |

### External Secrets Configuration

| Name                               | Description                                                                              | Value   |
| ---------------------------------- | ---------------------------------------------------------------------------------------- | ------- |
| `externalSecrets.create`           | Boolean indicating whether to create external secrets.                                   | `false` |
| `externalSecrets.apiVersion`       | API version for external secrets.                                                        | `""`    |
| `externalSecrets.name`             | Name of the external secret.                                                             | `""`    |
| `externalSecrets.labels`           | Labels for the external secret.                                                          | `{}`    |
| `externalSecrets.annotations`      | Annotations for the external secret.                                                     | `{}`    |
| `externalSecrets.spec`             | Specification details for the external secret.                                           | `{}`    |
| `serviceMonitor.enabled`           | Enable or disable the creation of ServiceMonitor for Prometheus monitoring.              | `false` |
| `serviceMonitor.name`              | Custom name for the ServiceMonitor resource. If left empty, a default name will be used. | `""`    |
| `serviceMonitor.labels`            | Labels to be added to the ServiceMonitor metadata for identification.                    | `{}`    |
| `serviceMonitor.annotations`       | Annotations to be added to the ServiceMonitor metadata.                                  | `{}`    |
| `serviceMonitor.matchLabels`       | Selector labels to match services that should be monitored.                              | `nil`   |
| `serviceMonitor.namespaceSelector` | Namespace selector to determine which namespaces are monitored.                          | `""`    |
| `serviceMonitor.port`              | The port name to scrape metrics from. This should match the service port name.           | `""`    |
| `serviceMonitor.path`              | HTTP path to scrape metrics from. Defaults to `/metrics` if not set.                     | `""`    |
| `serviceMonitor.honorLabels`       | Indicates whether to honor labels from the target service.                               | `true`  |
| `serviceMonitor.interval`          | Interval at which metrics should be scraped. Default is "30s".                           | `30s`   |
