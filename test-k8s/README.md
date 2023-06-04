### Commands

**Running the Go tests locally**

```bash
# Run the Kubernetes tests using the local Kubeconfig file.  Set TEST_ENV to either 'dev' or 'prod'.
export TEST_ENV=<dev|prod>
go test --kubeconfig ~/.kube/config
```

### Files

| Filename                   | Description                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------|
| `client.go`                | Kubernetes client creation.                                                                  |
| `main_test.go`             | Setup functions for Kubernetes tests.                                                        |
| `namespace_test.go`        | Kubernetes tests for the `saints-xctf` and `saints-xctf-dev` namespaces.                     |
| `saints_xctf_api_test.go`  | Kubernetes tests for `api.saintsxctf.com` Kubernetes objects.                                |
| `saints_xctf_test.go`      | Kubernetes tests for SaintsXCTF Kubernetes Ingress objects.                                  |
| `saints_xctf_web_test.go`  | Kubernetes tests for `saintsxctf.com` Kubernetes objects.                                    |
| `go.mod`                   | Go module definition and dependency specification.                                           |
| `go.sum`                   | Versions of modules installed as dependencies for this Go module.                            |
