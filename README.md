# vault-secrets-processor

An Alpine image installed with jq and yq processors to help fetching and rendering Vault secrets.

In a CI environment, you might need to fetch secrets from Vault for your app to execute unit tests for instance.

The following examle shows you how you can render the secrets at a specific location (a shared volume should be set for the secrets destination)

### Create a script the container will run

```sh
# Rendering configuration files for a Java-based application
TOKEN=$1
VAULT_SECRETS_PATH=$2
CONFIG_PATH=$3
ENVIRONMENTS=(
    default \
    codeship \
)

for env in "${ENVIRONMENTS[@]}"
    do
    curl \
        --header "X-Vault-Token: ${TOKEN}" \
        ${VAULT_SECRETS_PATH}/${env} | jq .data.data > payload.json

    cat payload.json | yq r -P - > ${CONFIG_PATH}/application-${env}.yml
done

rm -rf payload.json
```

### Declare a service

```yml
# codeship-services.yml
vault-secrets-processor-service:
  image: smarthelios/vault-secrets-processor
  encrypted_env_file: codeship.env.encrypted
  volumes:
    - ./.codeship/get-application-configuration.sh:/workspace/get-application-configuration.sh
    - .:/config
  cached: true
  default_cache_branch: "master"
```

### Write steps

```yml
# codeship-steps.yml
- name: 'get application configuration files'
  service: application-configuration-service
  command: /bin/bash -c 'chmod +x /workspace/get-application-configuration.sh && ./workspace/get-application-configuration.sh $CODESHIP_VAULT_TOKEN $VAULT_SECRETS_PATH $CONFIG_PATH'
  encrypted_dockercfg_path: dockercfg.encrypted

# Your app can now pick up the secrets (configuration files) at the location where the vault-secrets-processor stored them
- name: 'build aftercare-server-vault-test'
  service: build-service
  command: /bin/sh -c './gradlew -i -Dspring.config.location=file:///config/application-default.yml,file:///config/application-codeship.yml clean build javadoc test jacocoTestReport -Dsonar.host.url=https://sonarqube.pit.sh -Dsonar.login=${SONARQUBE_TOKEN} -Dsonar.scm.revision=${CI_COMMIT_ID} -Dsonar.buildString=${CI_COMMIT_ID} sonarqube'
  encrypted_dockercfg_path: dockercfg.encrypted
```