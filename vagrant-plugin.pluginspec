
Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = 'vagrant'
  plugin.display_name = 'Vagrant Plugin'
  plugin.version = '0.1.2'
  plugin.description = 'The Vagrant plugin allows you to bring up a Vagrant VM for the duration of your job'

  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/Vagrant+Plugin'
  plugin.developed_by 'rtyler', 'R. Tyler Croy <tyler@linux.com>'
  plugin.uses_repository :github => 'vagrant-plugin'

  plugin.depends_on 'ruby-runtime', '0.9'
end
