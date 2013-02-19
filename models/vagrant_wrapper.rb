require 'rubygems'
require 'vagrant'
require 'lockfile'
require 'tmpdir'

module Vagrant
  # This will handle proxying output from Vagrant into Jenkins
  class ConsoleInterface
    attr_accessor :listener, :resource

    def initialize(resource)
      @listener = nil
      @resource = resource
    end

    [:ask, :warn, :error, :info, :success].each do |method|
      define_method(method) do |message, *opts|
        @listener.info(message)
      end
    end

    [:clear_line, :report_progress].each do |method|
      # By default do nothing, these aren't logged
      define_method(method) do |*args|
      end
    end

    def ask(*args)
      super

      # Silent can't do this, obviously.
      raise Vagrant::Errors::UIExpectsTTY
    end
  end

  class BasicWrapper < Jenkins::Tasks::BuildWrapper
    display_name "Boot Vagrant box"

    attr_accessor :vagrantfile
    def initialize(attrs)
      @vagrant = nil
      @vagrantfile = attrs['vagrantfile']
    end

    def path_to_vagrantfile(build)
      if @vagrantfile.nil?
        return build.workspace.to_s
      end

      return FilePath.join(build.workspace.to_s, @vagrantfile)
    end

    # Called some time before the build is to start.
    def setup(build, launcher, listener)
      path = path_to_vagrantfile(build)

      unless FilePath.exists? FilePath.join(path, 'Vagrantfile')
        listener.info("There is no Vagrantfile in your workspace!")
        listener.info("We looked in: #{path}")
        build.native.setResult(Java.hudson.model.Result::NOT_BUILT)
        build.halt
      end

      listener.info("Running Vagrant with version: #{Vagrant::VERSION}")
      @vagrant = Vagrant::Environment.new(:cwd => path, :ui_class => ConsoleInterface)
      @vagrant.ui.listener = listener

      listener.info "Vagrantfile loaded, bringing Vagrant box up for the build"
      # Vagrant doesn't currently implement any locking, neither does
      # VBoxManage, and it will fail if importing two boxes concurrently, so use
      # a file lock to make sure that doesn't happen.
      Lockfile.new(File.join(Dir.tmpdir, ".vagrant-jenkins-plugin.lock")) do
        @vagrant.cli('up', '--no-provision')
      end
      listener.info "Vagrant box is online, continuing with the build"

      build.env[:vagrant] = @vagrant
      # We use this variable to determine if we have changes worth packaging,
      # i.e. if we have actually done anything with the box, we will mark it
      # dirty and can then take further action based on that
      build.env[:vagrant_dirty] = false
    end

    # Called some time when the build is finished.
    def teardown(build, listener)
      if @vagrant.nil?
        return
      end

      unless build.env[:vagrant_disable_destroy]
        listener.info "Build finished, destroying the Vagrant box"
        @vagrant.cli('destroy', '-f')
      end
    end
  end
end
