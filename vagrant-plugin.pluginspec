
Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = 'vagrant-plugin'
  plugin.version = '0.0.2'
  plugin.description = 'The Vagrant plugin allows you to bring up a Vagrant VM for the duration of your job'

  plugin.depends_on 'ruby-runtime', '0.9'
end
