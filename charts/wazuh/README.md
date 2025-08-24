# Wazuh Helm Chart

Cloud-agnostic Helm chart for deploying Wazuh with secure defaults and optional integrations.

## Prerequisites
- Kubernetes cluster 1.27+
- kubectl and Helm v3
- Metrics Server for HPA
- Ingress controller and cert-manager when using ingress/TLS

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `image.repository` | string | `ghcr.io/example/wazuh` | Container image repository |
| `image.tag` | string | `4.11.1` | Image tag |
| `replicaCount` | int | `2` | Number of replicas |
| `autoscaling.enabled` | bool | `true` | Enable HPA |
| `service.type` | string | `ClusterIP` | Service type |
| `service.port` | int | `80` | Service port |
| `ingress.enabled` | bool | `true` | Create ingress |
| `cloud.provider` | string | `generic` | Target cloud provider |
| `resources.requests.cpu` | string | `200m` | CPU request |
| `resources.limits.cpu` | string | `1` | CPU limit |

## Deploy-Any-Cloud Guide
1. **Prereqs**: kubectl, Helm v3, a Kubernetes cluster, and permissions. Ensure Metrics Server is installed. If using Ingress/TLS: install an ingress controller and cert-manager.
2. **Create namespace**:
   ```bash
   kubectl create namespace <ns>
   ```
3. **Inspect and validate**:
   ```bash
   helm lint ./charts/wazuh
   helm template ./charts/wazuh -n <ns> --values charts/wazuh/values.dev.yaml | kubeconform -strict -ignore-missing-schemas
   ```
4. **Install (dev example)**:
   ```bash
   helm install <release> ./charts/wazuh -n <ns> -f charts/wazuh/values.dev.yaml
   ```
5. **Verify**:
   ```bash
   kubectl -n <ns> rollout status deploy/<release>
   kubectl -n <ns> get pods,svc,hpa,ingress
   ```
6. **Enable autoscaling (if not default)**:
   ```bash
   helm upgrade <release> ./charts/wazuh -n <ns> --reuse-values --set autoscaling.enabled=true
   ```
7. **Trigger scale test (example)**:
   ```bash
   kubectl -n <ns> run hey --image=ghcr.io/rakyll/hey -it --rm -- <service-url>
   kubectl -n <ns> describe hpa <release>
   ```
8. **Ingress/TLS**:
   - Set `ingress.enabled=true`, `ingress.className`, hosts, and TLS secret in your values file.
9. **Clean up**:
   ```bash
   helm uninstall <release> -n <ns>
   ```

## Provider Notes
### EKS
- When `cloud.provider=eks` set ALB annotations under `cloud.lbAnnotations`.
- Consider IAM roles for service accounts for cloud permissions.
- Install Metrics Server from AWS Helm repository.

### GKE
- With `cloud.provider=gke` use GCE Ingress annotations in `cloud.lbAnnotations`.
- Ensure project has sufficient quota for load balancers.
- Metrics Server is pre-installed on Autopilot; otherwise install manually.

### AKS
- With `cloud.provider=aks` use AGIC or NGINX annotations accordingly in `cloud.lbAnnotations`.
- Configure managed identity when accessing Azure resources.
- For persistent volumes use `azure-file` or `azure-disk` StorageClasses.

## Troubleshooting
- Use `helm template` to inspect rendered manifests.
- Check events with `kubectl describe` for failing pods.
- Ensure network policies allow required traffic when enabled.

## Scaling Examples
- Scale up manually:
  ```bash
  kubectl -n <ns> scale deploy/<release> --replicas=5
  ```
- Scale down manually:
  ```bash
  kubectl -n <ns> scale deploy/<release> --replicas=1
  ```
- Observe HPA decisions:
  ```bash
  kubectl -n <ns> get hpa <release> -w
  ```
