### Overview

Creates Kubernetes, ALB, and ECR infrastructure for the SaintsXCTF API (V2).

### Commands

**Debugging**

```bash
export KUBECONFIG=~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster
kubectl get po -n saints-xctf-dev
kubectl logs -f api-pod-name -n saints-xctf-dev
```

### Directories

| Directory Name    | Description                                                                                     |
|-------------------|-------------------------------------------------------------------------------------------------|
| `env`             | Terraform configuration to build infrastructure for *DEV*, *PROD*, and global environments.     |
| `modules`         | Modules for building Kubernetes, ALB, and ECR infrastructure.                                   |