require 'rubygems'
require 'vagrant'


module Vagrant
  class PackagePublisher < Jenkins::Tasks::Publisher
    display_name "Package Vagrant box"

    attr_accessor :boxname
    def initialize(attrs)
      @vagrant = nil
      @boxname = attrs['boxname']
    end

    def prebuild(build, listener)
      # To run packaging, we need to own the destroy of the box
      build.env[:vagrant_disable_destroy] = true
    end

    def perform(build, launcher, listener)
      @vagrant = build.env[:vagrant]
      if @vagrant.nil?
        built.halt "OH CRAP! I don't seem to have a Vagrant instance in the publisher"
      end

      unless build.env[:vagrant_dirty]
        listener.info("It doesn't appear any changes were made inside the Vagrant VM")
        listener.info("I'm going to save us all a lot of grief and skip packaging it up then")
        return
      end

      name = @boxname
      if name.nil? or name.empty?
        name = 'package.box'
      end
      unless name.end_with? '.box'
        name = "#{name}.box"
      end

      listener.info("Preparing to export the current Vagrant box to a file named: #{name}")
      output = File.expand_path(File.join(build.workspace.to_s, name))
      @vagrant.cli('package', '--output', output)
      @vagrant.cli('destroy', '-f')
    end
  end
end
