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

// TestSaintsXCTFAPIFlaskDeploymentErrorFree determines if 'saints-xctf-api-flask-deployment' is running error free.
func TestSaintsXCTFAPIFlaskDeploymentErrorFree(t *testing.T) {
	k8sfuncs.DeploymentStatusCheck(t, ClientSet, "saints-xctf-api-flask-deployment", namespace, true, true, 1, 1, 1, 0)
}

// TestSaintsXCTFAPINginxDeploymentErrorFree determines if 'saints-xctf-api-nginx-deployment' is running error free.
func TestSaintsXCTFAPINginxDeploymentErrorFree(t *testing.T) {
	k8sfuncs.DeploymentStatusCheck(t, ClientSet, "saints-xctf-api-nginx-deployment", namespace, true, true, 1, 1, 1, 0)
}

// TestSaintsXCTFAPIServiceExists determines if a NodePort Service with the name 'saints-xctf-api' exists in the
// 'saints-xctf' (or 'saints-xctf-dev') namespace.
func TestSaintsXCTFAPIServiceExists(t *testing.T) {
	k8sfuncs.ServiceExists(t, ClientSet, "saints-xctf-api", namespace, "NodePort")
}

// TestSaintsXCTFAPIInternalServiceExists determines if a ClusterIP Service with the name 'saints-xctf-api-internal'
// exists in the 'saints-xctf' (or 'saints-xctf-dev') namespace.
func TestSaintsXCTFAPIInternalServiceExists(t *testing.T) {
	k8sfuncs.ServiceExists(t, ClientSet, "saints-xctf-api-internal", namespace, "ClusterIP")
}

// TestSaintsXCTFAPIFlaskServiceExists determines if a ClusterIP Service with the name 'jenkins-service' exists in the
//'saints-xctf' (or 'saints-xctf-dev') namespace.
func TestSaintsXCTFAPIFlaskServiceExists(t *testing.T) {
	k8sfuncs.ServiceExists(t, ClientSet, "saints-xctf-api-flask", namespace, "ClusterIP")
}