/**
 * Testing Kubernetes infrastructure for the web application 'api.saintsxctf.com'.
 * Author: Andrew Jarombek
 * Date: 2/21/2021
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	"testing"
)

// TestSaintsXCTFAPIFlaskDeploymentExists determines if a deployment exists in the 'saints-xctf' (or 'saints-xctf-dev')
// namespace with the name 'saints-xctf-api-flask-deployment'.
func TestSaintsXCTFAPIFlaskDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "saints-xctf-api-flask-deployment", namespace)
}

// TestSaintsXCTFAPINginxDeploymentExists determines if a deployment exists in the 'saints-xctf' (or 'saints-xctf-dev')
// namespace with the name 'saints-xctf-api-nginx-deployment'.
func TestSaintsXCTFAPINginxDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "saints-xctf-api-nginx-deployment", namespace)
}