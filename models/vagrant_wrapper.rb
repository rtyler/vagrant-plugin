require 'rubygems'
require 'vagrant'

class VagrantWrapper < Jenkins::Tasks::BuildWrapper

  display_name "Boot Vagrant box"

  # Called some time before the build is to start.
  def setup(build, launcher, listener, env)
    vagrant_file = build.workspace.to_s + "/Vagrantfile"
    unless File.exists? vagrant_file
      listener.info("There is no Vagrantfile in your workspace!")
      build.native.setResult(Java.hudson.model.Result::NOT_BUILT)
      build.halt
    end

    listener.info("Running Vagrant with version: #{Vagrant::VERSION}")
    listener.info "Bringing Vagrant box up for build"
    listener.info("Build object ID in builder: #{build.object_id}")
    native = Jenkins::Plugin.instance.export(self)
    # FFFFUUU
    native.makeBuildVariables(build.instance_variable_get(:@native), {"foo" => "bar"})
    #@vagrant = Vagrant::Environment.new.load!
    #@vagrant.primary_vm.up
    true
  end

  # Called some time when the build is finished.
  def teardown(build, listener, env)
    listener.info "Build finished, bringing down Vagrant box"
    #@vagrant.primary_vm.halt
    true
  end

end
