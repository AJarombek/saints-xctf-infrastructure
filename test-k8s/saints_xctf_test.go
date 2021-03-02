/**
 * Testing Kubernetes infrastructure shared amongst the SaintsXCTF web application and API.
 * Author: Andrew Jarombek
 * Date: 3/1/2021
 */

package main

import (
	"fmt"
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

// TestSaintsXCTFIngressExists determines if an ingress object exists in the 'saints-xctf' (or 'saints-xctf-dev')
// namespace with the name 'saints-xctf-com-ingress'.
func TestSaintsXCTFIngressExists(t *testing.T) {
	k8sfuncs.IngressExists(t, ClientSet, namespace, "saints-xctf-com-ingress")
}

// TestSaintsXCTFIngressAnnotations determines if the 'saints-xctf-com-ingress' Ingress object contains the expected annotations.
func TestSaintsXCTFIngressAnnotations(t *testing.T) {
	ingress, err := ClientSet.NetworkingV1beta1().Ingresses(namespace).Get("saints-xctf-com-ingress", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	var hostname string
	var environment string
	if env == "dev" {
		hostname = "dev.saintsxctf.com,www.dev.saintsxctf.com,dev.api.saintsxctf.com,www.dev.api.saintsxctf.com"
		environment = "development"
	} else {
		hostname = "saintsxctf.com,www.saintsxctf.com,api.saintsxctf.com,www.api.saintsxctf.com"
		environment = "production"
	}

	annotations := ingress.Annotations

	// Kubernetes Ingress class and ExternalDNS annotations
	k8sfuncs.AnnotationsEqual(t, annotations, "kubernetes.io/ingress.class", "alb")
	k8sfuncs.AnnotationsEqual(t, annotations, "external-dns.alpha.kubernetes.io/hostname", hostname)

	// ALB Ingress annotations
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/actions.ssl-redirect", "{\"Type\": \"redirect\", \"RedirectConfig\": {\"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/backend-protocol", "HTTP")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/scheme", "internet-facing")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/listen-ports", "[{\"HTTP\":80}, {\"HTTPS\":443}]")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/healthcheck-path", "/")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/healthcheck-protocol", "HTTP")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/target-type", "instance")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/tags", "Name=saints-xctf-com-load-balancer,Application=saints-xctf-com,Environment=" + environment)

	// ALB Ingress annotations pattern matching
	uuidPattern := "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
	certificateArnPattern := fmt.Sprintf("arn:aws:acm:us-east-1:739088120071:certificate/%s", uuidPattern)
	certificatesPattern := fmt.Sprintf("^%s,%s,%s,%s$", certificateArnPattern, certificateArnPattern, certificateArnPattern, certificateArnPattern)
	k8sfuncs.AnnotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/certificate-arn", certificatesPattern)

	sgPattern := "^sg-[0-9a-f]+$"
	k8sfuncs.AnnotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/security-groups", sgPattern)

	subnetsPattern := "^subnet-[0-9a-f]+,subnet-[0-9a-f]+$"
	k8sfuncs.AnnotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/subnets", subnetsPattern)

	expectedAnnotationsLength := 13
	annotationLength := len(annotations)

	if expectedAnnotationsLength == annotationLength {
		t.Logf(
			"Jenkins Ingress has the expected number of annotations.  Expected %v, got %v.",
			expectedAnnotationsLength,
			annotationLength,
		)
	} else {
		t.Errorf(
			"Jenkins Ingress does not have the expected number of annotations.  Expected %v, got %v.",
			expectedAnnotationsLength,
			annotationLength,
		)
	}
}