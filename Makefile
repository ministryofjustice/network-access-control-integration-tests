DOCKER_COMPOSE = docker-compose -f docker-compose.yml
ADMIN=network-access-control-admin
CLIENT=network-access-control-integration-tests

authenticate-docker:
	./authenticate_docker.sh

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

shell-schema-test-client:
	${DOCKER_COMPOSE} exec schema-test-client bash

shell-server:
	${DOCKER_COMPOSE} exec server bash

generate-certs:
	./test/scripts/generate_certs.sh

serve: stop serve-admin build-dev generate-certs bring-containers-up setup-ocsp

bring-containers-up:
	${DOCKER_COMPOSE} up -d ocsp
	${DOCKER_COMPOSE} up -d server
	${DOCKER_COMPOSE} up -d client
	${DOCKER_COMPOSE} up -d radsecproxy
	${DOCKER_COMPOSE} up -d schema-test-client

serve-admin:
	cd ${ADMIN} && make authenticate-docker build-dev db-setup serve && cd -

fetch-latest-policy-engine:
	curl https://raw.githubusercontent.com/ministryofjustice/network-access-control-server/main/radius/mods-config/python3/policyengine.py > ./policy_engine_schema_test_client/test/policy_engine.py

serve-schema-test-client: fetch-latest-policy-engine
	${DOCKER_COMPOSE} up -d --build schema-test-client

test-schema: serve-schema-test-client
	${DOCKER_COMPOSE} exec -T schema-test-client python3 ./test/test_schema.py

serve-server:
	${DOCKER_COMPOSE} stop server
	${DOCKER_COMPOSE} build server
	${DOCKER_COMPOSE} up -d server

test: serve
	$(DOCKER_COMPOSE) exec -T client bundle exec rspec

setup-ocsp:
	$(DOCKER_COMPOSE) exec -T ocsp /test/scripts/ocsp_responder.sh

.PHONY: stop clean clone-server clone-admin build shell-client serve test generate-certs setup-ocsp authenticate-docker run-client
