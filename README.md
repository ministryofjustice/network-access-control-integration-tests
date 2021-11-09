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

### Authenticating Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured with credentials for shared services, do the following to authenticate:

```bash
aws-vault exec SHARED_SERVICES_VAULT_PROFILE_NAME -- aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin SHARED_SERVICES_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com
```

Replace ```SHARED_SERVICES_VAULT_PROFILE_NAME``` and ```SHARED_SERVICES_ACCOUNT_ID``` in the command above with the profile name and ID of the shared services account configured in aws-vault.

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
