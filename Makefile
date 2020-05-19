SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t ranchertest/helm-controller:$(TAG) .

.PHONY: image-push
image-push:
	docker push ranchertest/helm-controller:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed ranchertest/helm-controller:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect ranchertest/helm-controller:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ranchertest/helm-controller:$(TAG) \
		$(shell docker image inspect ranchertest/helm-controller:$(TAG) | jq -r '.[] | .RepoDigests[0]')

