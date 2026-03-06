# c8r-network-agent Helm Chart

[![Helm](https://img.shields.io/badge/helm-v3-blue)](https://helm.sh)
[![Status](https://img.shields.io/badge/status-alpha-orange)](https://github.com)

> **⚠️ Alpha Release**: This chart is in alpha stage. APIs and configuration may change.

A Helm chart for deploying **c8r-network-agent** on Kubernetes for network traffic monitoring.

## Overview

c8r-network-agent monitors network traffic in your Kubernetes cluster by leveraging Linux conntrack to capture connection metadata.

### Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                          │
│                                                                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                          │
│  │  Node 1 │  │  Node 2 │  │  Node N │                          │
│  │ ┌─────┐ │  │ ┌─────┐ │  │ ┌─────┐ │                          │
│  │ │Agent│ │  │ │Agent│ │  │ │Agent│ │  (DaemonSet)             │
│  │ └──┬──┘ │  │ └──┬──┘ │  │ └──┬──┘ │                          │
│  └────┼────┘  └────┼────┘  └────┼────┘                          │
│       │            │            │                               │
│       └────────────┼────────────┘                               │
│                    │ gRPC                                       │
│                    ▼                                            │
│           ┌────────────────┐                                    │
│           │     Server     │  (Deployment)                      │
│           │  (aggregator)  │                                    │
│           └────────────────┘                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Components

- **Agent (DaemonSet)**: Runs on every node, collects network traffic data via conntrack
- **Server (Deployment)**: Aggregates data from agents and exports metrics

## Prerequisites

- Kubernetes 1.21+
- Helm 3.0+
- Linux nodes with conntrack support

## Installation
```bash
# Basic installation
helm install c8r-network-agent ./c8r-network-agent \
  --namespace monitoring \
  --create-namespace

# With custom values
helm install c8r-network-agent ./c8r-network-agent \
  --namespace monitoring \
  --create-namespace \
  --set environment=production \
  --set cloud=aws \
  --set region=us-east-1 \
  --set cluster=my-cluster
```

## Configuration

### Environment Variable Fallback

Every configuration parameter that maps to an app config field supports a companion `FromEnv` boolean flag. When set to `true`, the ConfigMap will render the corresponding environment variable reference (e.g. `${ENVIRONMENT}`) instead of a hardcoded value. This is useful when values are injected at runtime via Kubernetes Secrets or external secret managers.

```yaml
# Use a hardcoded value
environment: production
environmentFromEnv: false

# OR let the app read it from the ENVIRONMENT env var at runtime
environmentFromEnv: true
```

The env var names match the `env` struct tags in the application exactly (e.g. `ENVIRONMENT`, `CLOUD`, `REGION`, etc.).

---

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |
| `environment` | Environment name | `"development"` |
| `environmentFromEnv` | Read environment from `ENVIRONMENT` env var | `false` |
| `cloud` | Cloud provider (aws, azure, gcp) | `""` |
| `cloudFromEnv` | Read cloud from `CLOUD` env var | `false` |
| `region` | Cloud region | `""` |
| `regionFromEnv` | Read region from `REGION` env var | `false` |
| `cluster` | Cluster name | `""` |
| `clusterFromEnv` | Read cluster from `CLUSTER` env var | `false` |
| `organisationID` | Organisation ID | `""` |
| `organisationIDFromEnv` | Read organisation ID from `ORGANISATION_ID` env var | `false` |
| `clusterID` | Cluster ID | `""` |
| `clusterIDFromEnv` | Read cluster ID from `CLUSTER_ID` env var | `false` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `quay.io/cloudchipr/c8r-network-agent` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |
| `image.tag` | Image tag | `"v0.1.1-alpha"` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Service Account Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | SA annotations | `{}` |
| `serviceAccount.name` | SA name | `""` |

### Agent (DaemonSet) Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `configuration.agent.collectionInterval` | Collection interval | `5s` |
| `configuration.agent.skipConntrackSanityCheck` | Skip conntrack check | `false` |
| `configuration.agent.serverServiceHost` | Server host (auto-generated) | `""` |
| `configuration.agent.serverServicePort` | Server port | `8874` |
| `configuration.agent.uptimeWaitDuration` | Uptime wait duration | `300s` |
| `updateStrategy.type` | Update strategy | `RollingUpdate` |
| `updateStrategy.rollingUpdate.maxUnavailable` | Max unavailable | `50%` |

### Server (Deployment) Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.replicaCount` | Number of replicas | `3` |
| `deployment.strategy.type` | Deployment strategy | `RollingUpdate` |
| `deployment.affinity` | Pod affinity rules | See values.yaml |
| `deployment.topologySpreadConstraints` | Topology constraints | `[]` |
| `maxGRPCConnectionAge` | Max gRPC connection age | `300s` |
| `maxGRPCConnectionAgeFromEnv` | Read from `MAX_GRPC_CONNECTION_AGE` env var | `false` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | gRPC port | `8874` |
| `service.annotations` | Service annotations | `{}` |
| `grpcPortFromEnv` | Read gRPC port from `GRPC_PORT` env var | `false` |

### Metrics Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `metrics.enabled` | Enable metrics | `true` |
| `metrics.port` | Metrics port | `8873` |
| `metricsPortFromEnv` | Read metrics port from `METRICS_PORT` env var | `false` |
| `serviceMonitors.enabled` | Enable PodMonitor | `false` |
| `serviceMonitors.interval` | Scrape interval | `30s` |
| `serviceMonitors.scrapeTimeout` | Scrape timeout | `10s` |

### Exporter Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `exporter.numWorkers` | Number of export workers | `40` |
| `exporter.numWorkersFromEnv` | Read from `NUM_EXPORTER_WORKERS` env var | `false` |
| `exporter.ignoreUDP` | Ignore UDP traffic | `true` |
| `exporter.ignoreUDPFromEnv` | Read from `IGNORE_UDP` env var | `false` |
| `exporter.azureContainerURL` | Azure container URL | `""` |
| `exporter.azureContainerURLFromEnv` | Read from `AZURE_CONTAINER_URL` env var | `false` |

### Resource Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.agent.limits.cpu` | Agent CPU limit | `500m` |
| `resources.agent.limits.memory` | Agent memory limit | `256Mi` |
| `resources.agent.requests.cpu` | Agent CPU request | `50m` |
| `resources.agent.requests.memory` | Agent memory request | `64Mi` |
| `resources.server.limits.cpu` | Server CPU limit | `2000m` |
| `resources.server.limits.memory` | Server memory limit | `2512Mi` |
| `resources.server.requests.cpu` | Server CPU request | `500m` |
| `resources.server.requests.memory` | Server memory request | `1Gi` |

### Priority Class Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `priorityClass.enabled` | Enable priority class | `true` |
| `priorityClass.name` | Priority class name | `c8r-network-agent` |
| `priorityClass.value` | Priority value | `10001000` |
| `priorityClass.preemptionPolicy` | Preemption policy | `PreemptLowerPriority` |

### Security Context Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `securityContext.capabilities.add` | Added capabilities | `["NET_ADMIN"]` |
| `securityContext.capabilities.drop` | Dropped capabilities | `["ALL"]` |
| `securityContext.runAsUser` | Run as user | `0` |
| `securityContext.readOnlyRootFilesystem` | Read-only root FS | `true` |

### Probe Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.initialDelaySeconds` | Initial delay | `60` |
| `probes.liveness.periodSeconds` | Period | `30` |
| `probes.liveness.timeoutSeconds` | Timeout | `10` |
| `probes.liveness.failureThreshold` | Failure threshold | `3` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.initialDelaySeconds` | Initial delay | `15` |
| `probes.readiness.periodSeconds` | Period | `5` |
| `probes.readiness.timeoutSeconds` | Timeout | `5` |
| `probes.readiness.failureThreshold` | Failure threshold | `3` |

### Environment Variable Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env` | Additional environment variables for all pods | `[]` |
| `envFrom` | Environment variables from ConfigMaps or Secrets | `[]` |

---

## Examples

### Development
```bash
helm install c8r-network-agent ./c8r-network-agent \
  --namespace monitoring \
  --create-namespace \
  --set environment=development \
  --set deployment.replicaCount=1 \
  --set priorityClass.enabled=false \
  --set configuration.agent.skipConntrackSanityCheck=true
```

### Production (AWS)
```bash
helm install c8r-network-agent ./c8r-network-agent \
  --namespace monitoring \
  --create-namespace \
  --set environment=production \
  --set cloud=aws \
  --set region=us-east-1 \
  --set cluster=prod-cluster \
  --set organisationID=my-org-id \
  --set clusterID=my-cluster-id \
  --set deployment.replicaCount=5 \
  --set exporter.numWorkers=40
```

### Production (Azure)
```bash
helm install c8r-network-agent ./c8r-network-agent \
  --namespace monitoring \
  --create-namespace \
  --set environment=production \
  --set cloud=azure \
  --set region=eastus \
  --set cluster=prod-cluster \
  --set exporter.azureContainerURL="https://myaccount.blob.core.windows.net/container"
```

### Using Environment Variable Fallbacks (e.g. with External Secrets)
```yaml
# values.yaml
environmentFromEnv: true
cloudFromEnv: true
regionFromEnv: true
clusterFromEnv: true
organisationIDFromEnv: true
clusterIDFromEnv: true
exporter:
  azureContainerURLFromEnv: true
```

```yaml
# Pair with envFrom to inject values from a Secret at runtime
envFrom:
  - secretRef:
      name: c8r-runtime-config
```

---

## Troubleshooting

### Check pods
```bash
# Agent pods
kubectl get pods -n monitoring -l app.kubernetes.io/component=agent

# Server pods
kubectl get pods -n monitoring -l app.kubernetes.io/component=server
```

### View logs
```bash
# Agent logs
kubectl logs -n monitoring -l app.kubernetes.io/component=agent -f

# Server logs
kubectl logs -n monitoring -l app.kubernetes.io/component=server -f
```

### Verify conntrack
```bash
kubectl exec -n monitoring daemonset/c8r-network-agent-agent -- \
  cat /proc/sys/net/netfilter/nf_conntrack_acct
```

### Check config
```bash
kubectl get configmap -n monitoring c8r-network-agent-config -o yaml
```

## Uninstallation
```bash
helm uninstall c8r-network-agent --namespace monitoring

# Optional: Remove namespace
kubectl delete namespace monitoring
```
