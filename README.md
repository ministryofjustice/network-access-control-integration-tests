[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=flat&logo=github&labelColor=32393F&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fnetwork-access-control-integration-tests)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#network-access-control-integration-tests "Link to report")

# Network Access Control Integration Tests

This is the integration test suite for the Network Access Control (NAC) service.

## Getting Started
The integration test suite is dependent on the [Network Access Control Server](https://github.com/ministryofjustice/network-access-control-server) and [Network Access Control Admin](https://github.com/ministryofjustice/network-access-control-admin) repositories.

Clone the repositories:
```bash
make clone-server
```
and then
```bash
make clone-admin
```

### Authenticating with DockerHub

Local development shouldn't go over the download limits of Dockerhub.
https://docs.docker.com/docker-hub/download-rate-limit/

If these limits are encountered, authenticating with Docker is required:

```
export DOCKER_USERNAME=your-docker-hub-username
export DOCKER_PASSWORD=your-docker-hub-password

make authenticate-docker
```

### Running the integration tests
```bash
make test
```

### Run all containers (Admin Portal, Radsecproxy, test-client, NACS RADIUS Server, and CRL endpoint)
```bash
make serve
```

### Running the NACS Admin Portal
```bash
make serve-admin
```

### Running the NACS RADIUS Server
Note: the RADIUS server needs the Admin Portal to be running

```bash
make serve-server
```

### Running a single test
Shell into the Client - which runs the tests
```bash
make shell-client
```

Run an independent test:
```bash
bundle exec rspec ./spec/name_of_test_file.rb
```
