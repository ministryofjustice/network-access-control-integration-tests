DOCKER_COMPOSE = docker-compose -f docker-compose.yml
ADMIN=network-access-control-admin
CLIENT=network-access-control-integration-tests

authenticate-docker: check-container-registry-account-id
	./authenticate_docker.sh

check-container-registry-account-id:
	./check_container_registry_account_id.sh

stop:
	${DOCKER_COMPOSE} down
	cd ${ADMIN} && make stop && cd -

clean: stop
	rm -fr ./network-access-control-admin ./network-access-control-server

clone-admin:
	git clone https://github.com/ministryofjustice/network-access-control-admin.git

clone-server:
	git clone https://github.com/ministryofjustice/network-access-control-server.git

build-dev:
	${DOCKER_COMPOSE} build

shell-client: 
	${DOCKER_COMPOSE} exec client bash

shell-server:
	${DOCKER_COMPOSE} exec server bash

generate-certs:
	./test/scripts/generate_certs.sh

serve: stop serve-admin build-dev generate-certs
	${DOCKER_COMPOSE} up -d crl
	${DOCKER_COMPOSE} up -d server
	${DOCKER_COMPOSE} up -d client
	${DOCKER_COMPOSE} up -d radsecproxy

serve-admin:
	cd ${ADMIN} && make authenticate-docker build-dev db-setup serve && cd -

test: serve setup-tests 
	$(DOCKER_COMPOSE) exec -T client ./bootstrap.sh

setup-tests: setup-ocsp 

setup-ocsp:
	$(DOCKER_COMPOSE) exec -T server /test/scripts/ocsp_responder.sh

.PHONY: stop clean clone-server clone-admin build shell-client serve test generate-certs setup-ocsp authenticate-docker check-container-registry-account-id run-client
