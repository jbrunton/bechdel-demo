local steps = import '../../common/steps.libsonnet';

{
  env: {
    ENVIRONMENT: "${{ github.event.deployment.environment }}"
  },
  "if": "${{ github.event.deployment.task == 'deploy' }}",
  "runs-on": "ubuntu-latest",
  steps: [
    steps.checkout_with_token('CI_ADMIN_ACCESS_TOKEN'),
    steps.update_status("Deployment pending", "pending"),
    {
      name: "npm install",
      run: "npm install"
    },
    {
      id: "deployment_info",
      name: "deployment info",
      run: "npx ci set-outputs deployment-info $ENVIRONMENT"
    },
    {
      env: {
        HOST: "${{ steps.deployment_info.outputs.host }}",
        KEY: "${{ secrets.DEPLOYER_SSH_KEY }}",
        USERNAME: "deployer"
      },
      name: "copy files",
      uses: "appleboy/scp-action@master",
      with: {
        overwrite: true,
        source: "${{ steps.deployment_info.outputs.buildFile }},monitoring,docker-compose.monitoring.yml",
        target: "."
      }
    },
    {
      env: {
        BUILD_FILE: "${{ steps.deployment_info.outputs.buildFile }}",
        BUILD_VERSION: "${{ steps.deployment_info.outputs.buildVersion }}",
        HOST: "${{ steps.deployment_info.outputs.host }}",
        KEY: "${{ secrets.DEPLOYER_SSH_KEY }}",
        POSTGRES_CONNECTION: "${{ secrets.POSTGRES_PRODUCTION_CONNECTION }}",
        RAILS_MASTER_KEY: "${{ secrets.RAILS_PRODUCTION_MASTER_KEY }}",
        USERNAME: "deployer"
      },
      name: "deploy",
      uses: "appleboy/ssh-action@master",
      with: {
        envs: "POSTGRES_CONNECTION,RAILS_MASTER_KEY,BUILD_FILE,BUILD_VERSION",
        script: "ln -sf $BUILD_FILE docker-compose.yml\nexport BUILD_VERSION\nexport POSTGRES_CONNECTION\nexport RAILS_MASTER_KEY\nexport COMPOSE_FILE=\"docker-compose.yml:docker-compose.monitoring.yml\"\ndocker-compose up --detach --no-build --remove-orphans\ndocker-compose run api bin/rails db:migrate\n"
      }
    },
    {
      name: "commit",
      run: "git config --global user.email \"jbrunton-ci-minion@outlook.com\"\ngit config --global user.name \"jbrunton-ci-minion\"\n\nnpx ci commit deployment $ENVIRONMENT\n\ngit push origin HEAD:master\n"
    },
    { "if": "success()" } + steps.update_status("notify success", "success"),
    { "if": "failure()" } + steps.update_status("notify failure", "failure"),
  ]
}
