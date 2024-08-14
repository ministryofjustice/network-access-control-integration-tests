DOCKER_COMPOSE = docker-compose -f docker-compose.yml
ADMIN=network-access-control-admin
CLIENT=network-access-control-integration-tests

.DEFAULT_GOAL := help

.PHONY: authenticate_docker
authenticate-docker: ## Authenticate docker script
	./authenticate_docker.sh

.PHONY: stop
stop: ## Stop docker container
	${DOCKER_COMPOSE} down
	cd ${ADMIN} && make stop && cd -

.PHONY: clean
clean: ## Stop docker container and remove nacs-admin and nacs-server repos
	$(MAKE) stop
	rm -fr ./network-access-control-admin ./network-access-control-server

.PHONY: clone-admin
clone-admin: ## Clone nacs admin repo
	git clone https://github.com/ministryofjustice/network-access-control-admin.git

.PHONY: clone-server
clone-server: ## Clone nacs server repo
	git clone git@github.com:ministryofjustice/network-access-control-server && \
	cd network-access-control-server && \
	git checkout -b ND-463-debug-latest-nac-server

.PHONY: build-dev
build-dev: ## Build dev docker container
	${DOCKER_COMPOSE} build

.PHONY: shell-client
shell-client: ## Executes bash session within client
	${DOCKER_COMPOSE} exec client bash

.PHONY: shell-schema-test-client
shell-schema-test-client: ## Executes bash session within schema-test-client
	${DOCKER_COMPOSE} exec schema-test-client bash

.PHONY: shell-server
shell-server: ## Executes bash session within server
	${DOCKER_COMPOSE} exec server bash

.PHONY: generate_certs
generate-certs: ## Run generate certs script
	./test/scripts/generate_certs.sh

.PHONY: serve
serve: ## Generate certs, bring dev containers up and run ocsp_responder in oscp container
	$(MAKE) stop
	$(MAKE) serve-admin
	$(MAKE) build-dev
	$(MAKE) generate-certs
	$(MAKE) bring-containers-up
	$(MAKE) setup-ocsp

.PHONY: bring-containers-up
bring-containers-up: ## Bring all containers up - oscp, server, client, radsecproxy, schema-test-client
	${DOCKER_COMPOSE} up -d ocsp
	${DOCKER_COMPOSE} up -d server
	${DOCKER_COMPOSE} up -d client
	${DOCKER_COMPOSE} up -d radsecproxy
	${DOCKER_COMPOSE} up -d schema-test-client

.PHONY: serve-admin
serve-admin: ## Move into nacs admin dile, generate certs, bring dev containers up and run ocsp_responder in oscp container
	cd ${ADMIN} && $(MAKE) authenticate-docker build-dev serve && cd -

.PHONY: fetch-latest-policy-engine
fetch-latest-policy-engine: ## Fetch latest radius policy engine
	curl https://raw.githubusercontent.com/ministryofjustice/network-access-control-server/main/radius/mods-config/python3/policyengine.py > ./policy_engine_schema_test_client/test/policy_engine.py

.PHONY: serve-schema-test-client
serve-schema-test-client: ## Fetch latest radius policy engine and build schema-test-client
	$(MAKE) fetch-latest-policy-engine
	${DOCKER_COMPOSE} up -d --build schema-test-client

.PHONY: test-schema
test-schema: ## Build schema-test and run tests
	$(MAKE) serve-schema-test-client
	${DOCKER_COMPOSE} exec -T schema-test-client python3 ./test/test_schema.py

.PHONY: serve-server
serve-server: ## Build server container
	${DOCKER_COMPOSE} stop server
	${DOCKER_COMPOSE} build server
	${DOCKER_COMPOSE} up -d server

.PHONY: test
test: ## Build all containers and run tests
	$(MAKE) serve
	$(DOCKER_COMPOSE) exec -T client bundle exec rspec

.PHONY: setup-oscp
setup-ocsp: ## Run ocsp_responder script in ocsp container
	$(DOCKER_COMPOSE) exec -T ocsp /test/scripts/ocsp_responder.sh

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
