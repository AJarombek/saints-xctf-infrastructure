/**
 * Testing Kubernetes infrastructure for the web application 'saintsxctf.com'.
 * Author: Andrew Jarombek
 * Date: 2/21/2021
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	"testing"
)

// TestSaintsXCTFComDeploymentExists determines if a deployment exists in the 'saints-xctf' namespace with the name
// 'saints-xctf-web-deployment'.
func TestSaintsXCTFComDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "saints-xctf-web-deployment", namespace)
}

// TestSaintsXCTFComDeploymentErrorFree determines if 'saints-xctf-web-deployment' is running error free.
func TestSaintsXCTFComDeploymentErrorFree(t *testing.T) {
	k8sfuncs.DeploymentStatusCheck(t, ClientSet, "saints-xctf-web-deployment", namespace, true, true, 1, 1, 1, 0)
}

// TestSaintsXCTFComServiceExists determines if a NodePort Service with the name 'jenkins-service' exists in the 'jenkins'
// namespace.
func TestSaintsXCTFComServiceExists(t *testing.T) {
	k8sfuncs.ServiceExists(t, ClientSet, "saints-xctf-web-service", namespace, "NodePort")
}