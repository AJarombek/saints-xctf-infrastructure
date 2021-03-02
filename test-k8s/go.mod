// Go module definition for the saints-xctf-k8s-infrastructure-tests module.
// Author: Andrew Jarombek
// Date: 2/21/2021

module github.com/ajarombek/saints-xctf-k8s-infrastructure-tests

go 1.14

require (
	github.com/ajarombek/cloud-modules/kubernetes-test-functions v0.2.10
	k8s.io/apimachinery v0.17.3-beta.0
	k8s.io/client-go v0.17.0
)
