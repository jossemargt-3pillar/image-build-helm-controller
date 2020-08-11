SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/helm-controller:$(TAG) .

.PHONY: image-push
image-push:
	docker push rancher/helm-controller:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/helm-controller:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/helm-controller:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/helm-controller:$(TAG) \
		$(shell docker image inspect rancher/helm-controller:$(TAG) | jq -r '.[] | .RepoDigests[0]')

