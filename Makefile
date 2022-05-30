REGISTRY_URL=257d4576.gra7.container-registry.ovh.net
RUBY_VERSION=2.3.8

docker:
	read -p "Version image? " IMAGE_VERSION && \
	docker build -t ${REGISTRY_URL}/estimancy/estimancy:$${IMAGE_VERSION} --build-arg RUBY_VERSION=${RUBY_VERSION} .

.PHONY: docker