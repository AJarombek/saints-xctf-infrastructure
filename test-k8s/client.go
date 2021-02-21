/**
 * Utilities for getting a client connection to the Kubernetes cluster.
 * Author: Andrew Jarombek
 * Date: 2/21/2021
 */

package main

import (
	"flag"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

// GetClientSet gets a Kubernetes Clientset object which enables interaction with the Kubernetes cluster.
// Parameter: kubeconfig - Path of a KubeConfig file used to authenticate with the Kubernetes cluster
// (from outside the cluster).
// Parameter: inCluster - Whether or not the Go K8s client is connecting to the Kubernetes cluster from a pod inside
// the cluster or a machine outside the cluster.  If connecting from inside the cluster, the pods ServiceAccount is
// used to authenticate.  Otherwise, the KubeConfig file is used.
func GetClientSet(kubeconfig *string, inCluster *string) *kubernetes.Clientset {
	var config *rest.Config
	var err error

	if *inCluster == "true" {
		config, err = rest.InClusterConfig()

		if err != nil {
			panic(err.Error())
		}
	} else {
		config, err = clientcmd.BuildConfigFromFlags("", *kubeconfig)

		if err != nil {
			panic(err.Error())
		}
	}

	clientset, err := kubernetes.NewForConfig(config)

	if err != nil {
		panic(err.Error())
	}

	return clientset
}

// ParseCommandLineArguments gets a KubeConfig file path (--kubeconfig) and a boolean of whether or not the application
// is connecting to Kubernetes from within the cluster (--incluster) from command line flags.
func ParseCommandLineArguments() (*string, *string) {
	var kubeconfig *string = flag.String("kubeconfig", "", "Absolute path to the kubeconfig file.")
	var inCluster *string = flag.String("incluster", "", "Whether or not the tests are running in a cluster.")
	flag.Parse()

	return kubeconfig, inCluster
}
