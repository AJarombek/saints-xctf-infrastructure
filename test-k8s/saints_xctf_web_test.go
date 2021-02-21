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