local workflow = {
  env: {
    CI: 1,
    FORCE_COLOR: 1,
    WORKSPACE: "${{ github.workspace }}"
  },
  jobs: {
    build: {
      env: {
        DOCKER_ACCESS_TOKEN: "${{ secrets.DOCKER_ACCESS_TOKEN }}",
        DOCKER_USERNAME: "jbrunton"
      },
      "if": "${{ needs.manifest_check.outputs.buildRequired == true }}",
      needs: "manifest_check",
      "runs-on": "ubuntu-latest",
      steps: [
        {
          uses: "actions/checkout@v2",
          with: {
            token: "${{ secrets.CI_ADMIN_ACCESS_TOKEN }}"
          }
        },
        {
          name: "npm install",
          run: "npm install"
        },
        {
          name: "docker login",
          run: "echo \"$DOCKER_ACCESS_TOKEN\" | docker login -u \"$DOCKER_USERNAME\" --password-stdin"
        },
        {
          name: "build",
          run: "npx ci create build"
        },
        {
          name: "commit",
          run: "git config --global user.email \"jbrunton-ci-minion@outlook.com\"\ngit config --global user.name \"jbrunton-ci-minion\"\n\nnpx ci commit build\n\ngit push origin HEAD:master\n"
        }
      ]
    },
    deploy_existing_build: {
      "if": "needs.manifest_check.outputs.deploymentsRequired == true \u0026\u0026 needs.manifest_check.outputs.buildRequired == false",
      needs: "manifest_check",
      "runs-on": "ubuntu-latest",
      steps: [
        {
          uses: "actions/checkout@v2"
        },
        {
          name: "npm install",
          run: "npm install"
        },
        {
          env: {
            ENVIRONMENT: "${{ matrix.environment }}",
            TASK: "${{ matrix.task }}"
          },
          id: "payload",
          name: "generate payload",
          run: "npx ci set-outputs deploy-payload $ENVIRONMENT"
        },
        {
          env: {
            GITHUB_TOKEN: "${{ secrets.CI_MINION_ACCESS_TOKEN }}",
            PAYLOAD: "${{ steps.payload.outputs.payload }}"
          },
          name: "start deployment workflow",
          run: "echo \"${PAYLOAD}\" | hub api \"repos/jbrunton/bechdel-lists/deployments\" --input -"
        }
      ],
      strategy: {
        matrix: "${{ fromJson(needs.manifest_check.outputs.deploymentMatrix) }}"
      }
    },
    deploy_new_build: {
      "if": "needs.manifest_check.outputs.deploymentsRequired == true \u0026\u0026 needs.manifest_check.outputs.buildRequired == true",
      needs: [
        "manifest_check",
        "build"
      ],
      "runs-on": "ubuntu-latest",
      steps: [
        {
          uses: "actions/checkout@v2"
        },
        {
          name: "npm install",
          run: "npm install"
        },
        {
          env: {
            ENVIRONMENT: "${{ matrix.environment }}",
            TASK: "${{ matrix.task }}"
          },
          id: "payload",
          name: "generate payload",
          run: "npx ci set-outputs deploy-payload $ENVIRONMENT"
        },
        {
          env: {
            GITHUB_TOKEN: "${{ secrets.CI_MINION_ACCESS_TOKEN }}",
            PAYLOAD: "${{ steps.payload.outputs.payload }}"
          },
          name: "start deployment workflow",
          run: "echo \"${PAYLOAD}\" | hub api \"repos/jbrunton/bechdel-lists/deployments\" --input -"
        }
      ],
      strategy: {
        matrix: "${{ fromJson(needs.manifest_check.outputs.deploymentMatrix) }}"
      }
    },
    integration_tests: {
      "runs-on": "ubuntu-latest",
      steps: [
        {
          uses: "actions/checkout@v2"
        },
        {
          name: "copy .env",
          run: "cp ci/ci.env .env"
        },
        {
          env: {
            SERVICE: "${{ matrix.service }}"
          },
          name: "run",
          run: "./ci/integration_tests/${SERVICE}.sh"
        }
      ],
      strategy: {
        matrix: {
          service: [
            "api",
            "client"
          ]
        }
      }
    },
    manifest_check: {
      needs: [
        "unit_tests",
        "integration_tests"
      ],
      outputs: {
        buildRequired: "${{ steps.check.outputs.buildRequired }}",
        deploymentMatrix: "${{ steps.check.outputs.deploymentMatrix }}",
        deploymentsRequired: "${{ steps.check.outputs.deploymentsRequired }}"
      },
      "runs-on": "ubuntu-latest",
      steps: [
        {
          uses: "actions/checkout@v2"
        },
        {
          id: "check",
          "if": "github.event.ref == 'refs/heads/master'",
          name: "check manifest",
          run: "npm install\nnpx ci set-outputs manifest-checks\n"
        }
      ]
    },
    unit_tests: {
      "runs-on": "ubuntu-latest",
      steps: [
        {
          uses: "actions/checkout@v2"
        },
        {
          uses: "ruby/setup-ruby@v1",
          with: {
            "ruby-version": "2.6.3"
          }
        },
        {
          name: "copy .env",
          run: "cp ci/ci.env .env"
        },
        {
          env: {
            SERVICE: "${{ matrix.service }}"
          },
          name: "run unit tests",
          run: "./ci/unit_tests/${SERVICE}.sh"
        }
      ],
      strategy: {
        matrix: {
          service: [
            "api",
            "client"
          ]
        }
      }
    }
  },
  name: "ci-build",
  on: {
    pull_request: {
      branches: [
        "master"
      ]
    },
    push: {
      branches: [
        "master"
      ],
      "paths-ignore": [
        "deployments/**"
      ]
    }
  }
};

std.manifestYamlDoc(workflow)
