require 'rubygems'
require 'vagrant'

class VagrantWrapper < Jenkins::Tasks::BuildWrapper
  display_name "Boot Vagrant box"

  def initialize(*args)
    @vagrant = nil
    super(*args)
  end

  # Called some time before the build is to start.
  def setup(build, launcher, listener)
    vagrant_file = build.workspace.to_s + "/Vagrantfile"

    unless File.exists? vagrant_file
      listener.info("There is no Vagrantfile in your workspace!")
      build.native.setResult(Java.hudson.model.Result::NOT_BUILT)
      build.halt
    end

    listener.info("Running Vagrant with version: #{Vagrant::VERSION}")
    @vagrant = Vagrant::Environment.new(:cwd => build.workspace.to_s)
    listener.info "Vagrantfile loaded, bringing Vagrant box up for the build"
    @vagrant.cli('up')
    listener.info "Vagrant box is online, continuing with the build"
  end

  # Called some time when the build is finished.
  def teardown(build, listener)
    listener.info "Build finished, destroying the Vagrant box"
    unless @vagrant.nil?
      @vagrant.cli('destroy', '-f')
    end
  end
end
