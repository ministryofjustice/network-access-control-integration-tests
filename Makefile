ADMIN=network-access-control-admin
SERVER=network-access-control-server

stop:
	cd ${SERVER} && make stop && cd -
	cd ${ADMIN} && make stop && cd -

clean: stop
	rm -fr ./network-access-control-admin ./network-access-control-server

clone-admin:
	git clone git@github.com:ministryofjustice/network-access-control-admin.git

clone-server:
	git clone git@github.com:ministryofjustice/network-access-control-server.git

serve: stop
	cd ${ADMIN} && make authenticate-docker build-dev db-setup serve && cd -
	cd ${SERVER} && make authenticate-docker build-dev generate-certs serve && cd -

test: serve
	cd ${SERVER} && make test && cd -

.PHONY: run build stop clone-server clone-admin
