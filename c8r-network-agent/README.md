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

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full chart name | `""` |
| `environment` | Environment name | `"development"` |
| `cloud` | Cloud provider (aws, azure, gcp) | `""` |
| `region` | Cloud region | `""` |
| `cluster` | Cluster name | `""` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `ghcr.io/c8r/network-agent` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |
| `image.tag` | Image tag | `""` (uses appVersion) |
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
| `configuration.agent.serverServicePort` | Server port | `8884` |
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

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | gRPC port | `8884` |
| `service.annotations` | Service annotations | `{}` |

### Metrics Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `metrics.enabled` | Enable metrics | `true` |
| `metrics.port` | Metrics port | `8883` |
| `serviceMonitors.enabled` | Enable PodMonitor | `false` |
| `serviceMonitors.interval` | Scrape interval | `30s` |

### Exporter Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `exporter.numWorkers` | Number of workers | `20` |
| `exporter.ignoreUDP` | Ignore UDP traffic | `true` |
| `exporter.azureContainerURL` | Azure container URL | `""` |

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
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.initialDelaySeconds` | Initial delay | `15` |
| `probes.readiness.periodSeconds` | Period | `5` |

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
