.PHONY: build push

DEPLOY_NAMESPACE = moop-dev
TAG			= $(shell git describe --tags --always)
REGISTRY	= registry.datadynamic.io/moop
IMAGE		= moop-pod-service


build: 
	docker build --rm -t "$(REGISTRY)/$(IMAGE):$(TAG)" -f Dockerfile .

push: build
	docker push "$(REGISTRY)/$(IMAGE):$(TAG)"

deploy: push
	# replace image tag on deployment.yaml
	sed -i 's/{IMAGE_TAG}/$(TAG)/g' deploy/pod-service-deployment.yaml
	# apply change
	kubectl apply -f deploy/ --namespace "$(DEPLOY_NAMESPACE)"
	# restore depo
	sed -i 's/$(TAG)/{IMAGE_TAG}/g' deploy/pod-service-deployment.yaml

