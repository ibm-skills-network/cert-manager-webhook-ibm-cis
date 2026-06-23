package main

import (
	"os"
	"testing"

	acmetest "github.com/cert-manager/cert-manager/test/acme"
)

var (
	zone      = os.Getenv("TEST_ZONE_NAME")
	dnsRecord = os.Getenv("TEST_DNS_RECORD")
	// One of the CIS zone's authoritative nameservers. Override per zone with
	// TEST_DNS_SERVER (address:port).
	dnsServer = envOrDefault("TEST_DNS_SERVER", "ns053.name.cloud.ibm.com:53")
)

func envOrDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func TestRunsSuite(t *testing.T) {
	solver := &ibmCloudCisProviderSolver{}
	fixture := acmetest.NewFixture(solver,
		acmetest.SetStrict(true),
		acmetest.SetDNSName(dnsRecord),
		acmetest.SetResolvedZone(zone),
		acmetest.SetManifestPath("testdata/ibm-cloud-cis"),
		// Query the zone's authoritative nameserver directly. The propagation
		// and deletion checks otherwise poll a public recursive resolver
		// (8.8.8.8), which returns inconsistent NXDOMAIN/SERVFAIL answers for a
		// record that is mid-create/delete, making the suite flaky.
		acmetest.SetDNSServer(dnsServer),
		acmetest.SetUseAuthoritative(true),
	)
	fixture.RunConformance(t)

}
