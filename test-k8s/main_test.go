/**
 * Main functions to set up the Kubernetes test suite.
 * Author: Andrew Jarombek
 * Date: 2/21/2021
 */

package main

import (
	"k8s.io/client-go/kubernetes"
	"os"
	"testing"
)

var ClientSet *kubernetes.Clientset

// Setup code for the test suite.
func TestMain(m *testing.M) {
	kubeconfig, inCluster := ParseCommandLineArguments()
	ClientSet = GetClientSet(kubeconfig, inCluster)
	os.Exit(m.Run())
}