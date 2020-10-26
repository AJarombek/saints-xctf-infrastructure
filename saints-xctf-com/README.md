### Overview

Creates Kubernetes, ALB, and ECR infrastructure for the SaintsXCTF web application (V2).

### Commands

**Debugging the Kubernetes infrastructure**

```bash
 kubectl get po -n saints-xctf-dev
 kubectl describe po -n saints-xctf-dev
```

### Directories

| Directory Name    | Description                                                                                     |
|-------------------|-------------------------------------------------------------------------------------------------|
| `env`             | Terraform configuration to build infrastructure for *DEV*, *PROD*, and global environments.     |
| `modules`         | Modules for building Kubernetes, ALB, and ECR infrastructure.                                   |