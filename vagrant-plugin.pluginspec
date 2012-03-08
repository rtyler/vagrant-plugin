
Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = 'vagrant-plugin'
  plugin.version = '0.0.2'
  plugin.description = 'Vagrant rocks'

  plugin.depends_on 'ruby-runtime', '0.9'
end
