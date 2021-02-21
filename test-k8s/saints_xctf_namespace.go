/**
 * Testing Kubernetes infrastructure in the 'saints-xctf' or 'saints-xctf-dev' namespaces.
 * Author: Andrew Jarombek
 * Date: 2/21/2021
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	"testing"
)

// TestSaintsXCTFNamespaceDeploymentCount determines if the number of 'Deployment' objects in the 'saints-xctf'
// (or 'saints-xctf-dev') namespace is as expected.
func TestSaintsXCTFNamespaceDeploymentCount(t *testing.T) {
	k8sfuncs.ExpectedDeploymentCount(t, ClientSet, namespace, 3)
}