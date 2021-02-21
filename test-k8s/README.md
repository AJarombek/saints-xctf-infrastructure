### Commands

**Running the Go tests locally**

```bash
# Run the Kubernetes tests using the local Kubeconfig file.
go test --kubeconfig ~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster
```

### Files

| Filename                   | Description                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------|
| `client.go`                | Kubernetes client creation.                                                                  |
| `main_test.go`             | Setup functions for Kubernetes tests.                                                        |
| `saints_xctf_web_test.go`  | Kubernetes tests for `saintsxctf.com` Kubernetes objects.                                    |
| `go.mod`                   | Go module definition and dependency specification.                                           |
| `go.sum`                   | Versions of modules installed as dependencies for this Go module.                            |
