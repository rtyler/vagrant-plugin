
Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = 'vagrant-plugin'
  plugin.version = '0.0.1'
  plugin.description = 'enter description here'

  plugin.depends_on 'ruby-runtime', '0.3'
  plugin.depends_on 'git', '1.1.11'
end