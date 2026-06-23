GO ?= $(shell which go)
OS ?= $(shell $(GO) env GOOS)
ARCH ?= $(shell $(GO) env GOARCH)

IMAGE_NAME := "icr.io/skills-network/cert-manager-webhook-ibm-cis"
IMAGE_TAG := "latest"

OUT := $(shell pwd)/_out

ENVTEST_K8S_VERSION=1.35.0

HELM_FILES := $(shell find deploy/cert-manager-ibm-cis-webhook)

test:
	ASSETS="$$($(GO) run sigs.k8s.io/controller-runtime/tools/setup-envtest@latest use $(ENVTEST_K8S_VERSION) --bin-dir _test -p path)"; \
	TEST_ASSET_ETCD="$$ASSETS/etcd" \
	TEST_ASSET_KUBE_APISERVER="$$ASSETS/kube-apiserver" \
	TEST_ASSET_KUBECTL="$$ASSETS/kubectl" \
	KUBEBUILDER_ASSETS="$$ASSETS" \
	$(GO) test -v .

.PHONY: clean
clean:
	rm -r _test $(OUT)

.PHONY: build
build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml: $(OUT)/rendered-manifest.yaml

$(OUT)/rendered-manifest.yaml: $(HELM_FILES) | $(OUT)
	helm template \
	    --name cert-manager-ibm-cis-webhook \
            --set image.repository=$(IMAGE_NAME) \
            --set image.tag=$(IMAGE_TAG) \
            deploy/cert-manager-ibm-cis-webhook > $@

_test $(OUT):
	mkdir -p $@
