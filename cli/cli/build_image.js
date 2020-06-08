const { spawn } = require('../lib/child_process');
const manifests = require('../lib/manifests');

module.exports = {
  flags: 'build-image <service> <build-target>',
  desc: 'Builds a docker image for the specified service',
  params: [
    { type: 'service', strict: true },
    { type: 'build-target', strict: true }
  ],
  run: async (argv, context) => {
    const dryRun = argv['dry-run'];
    
    const service = argv.service;
    const manifest = await manifests.local.getServiceManifest(service);
    const buildArgs = manifest?.build?.buildArgs || [];
    const imageName = argv['build-target'] == 'dev' ? `bechdel-images-${service}` : `jbrunton/bechdel-images-${service}`;
    const imageTag = `${imageName}:${process.env.TAG || 'latest'}`;
    const commandBuilder = [
      'docker build',
      `--target ${argv['build-target']}`,
      `--tag ${imageTag}`,
      buildArgs.map(buildArg => `--build-arg ${buildArg}`).join(' '),
      `services/${service}`
    ].filter(command => command.trim().length > 0);

    const command = commandBuilder.join(' ');

    if (!dryRun) {
      await spawn(command, { env: process.env });
    } else {
      console.log('--dry-run passed, skipping task. Would have run:');
      console.log(command);
    }
  }
};
