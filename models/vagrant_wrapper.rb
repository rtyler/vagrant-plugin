require 'rubygems'
require 'vagrant'

module Vagrant
  # This will handle proxying output from Vagrant into Jenkins
  class ConsoleInterface
    attr_accessor :listener, :resource

    def initializer(resource)
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

      return File.expand_path(File.join(build.workspace.to_s, @vagrantfile))
    end

    # Called some time before the build is to start.
    def setup(build, launcher, listener)
      path = path_to_vagrantfile(build)

      unless File.exists? File.join(path, 'Vagrantfile')
        listener.info("There is no Vagrantfile in your workspace!")
        listener.info("We looked in: #{path}")
        build.native.setResult(Java.hudson.model.Result::NOT_BUILT)
        build.halt
      end

      listener.info("Running Vagrant with version: #{Vagrant::VERSION}")
      @vagrant = Vagrant::Environment.new(:cwd => path, :ui_class => ConsoleInterface)
      @vagrant.ui.listener = listener

      listener.info "Vagrantfile loaded, bringing Vagrant box up for the build"
      @vagrant.cli('up', '--no-provision')
      listener.info "Vagrant box is online, continuing with the build"

      build.env[:vagrant] = @vagrant
    end

    # Called some time when the build is finished.
    def teardown(build, listener)
      listener.info "Build finished, destroying the Vagrant box"
      unless @vagrant.nil?
        @vagrant.cli('destroy', '-f')
      end
    end
  end
end
