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
    if env == "prod" {
	    k8sfuncs.ExpectedDeploymentCount(t, ClientSet, namespace, 3)
    } else {
        k8sfuncs.ExpectedDeploymentCount(t, ClientSet, namespace, 0)
    }
}

// TestSaintsXCTFNamespaceServiceCount determines if the expected number of Service objects exist in the 'saints-xctf'
// (or 'saints-xctf-dev') namespace.
func TestSaintsXCTFNamespaceServiceCount(t *testing.T) {
    if env == "prod" {
	    k8sfuncs.NamespaceServiceCount(t, ClientSet, namespace, 4)
    } else {
        k8sfuncs.NamespaceServiceCount(t, ClientSet, namespace, 0)
    }
}

// TestSaintsXCTFNamespaceIngressCount determines if the number of 'Ingress' objects in the 'saints-xctf'
// (or 'saints-xctf-dev') namespace is as expected.
func TestSaintsXCTFNamespaceIngressCount(t *testing.T) {
    // TODO Fix Ingress Tests
	t.Skip("Skipping test due to k8s client issue")

    if env == "prod" {
	    k8sfuncs.NamespaceIngressCount(t, ClientSet, namespace, 1)
    } else {
        k8sfuncs.NamespaceIngressCount(t, ClientSet, namespace, 0)
    }
}