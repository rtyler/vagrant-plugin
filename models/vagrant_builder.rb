require 'rubygems'
require 'vagrant'


module Vagrant
  module BaseBuilder
    def prebuild(build, listener)
    end

    def perform(build, launcher, listener)
      # This should be set by the VagrantWrapper
      @vagrant = build.env[:vagrant]

      if @vagrant.nil?
        build.halt "OH CRAP! I don't seem to have a Vagrant instance!"
      end

      if @vagrant.multivm?
          perform_multi_vm(build, launcher, listener)
      else
          perform_single_vm(build, launcher, listener)
      end
    end

    def perform_single_vm(build, launcher, listener)
        unless @vagrant.primary_vm.state == :running
            build.halt "Vagrant VM doesn't appear to be running!"
        end

        listener.info("Running the command in Vagrant with \"#{vagrant_method.to_s}\":")
        @command.split("\n").each do |line|
            listener.info("+ #{line}")
        end

        code = @vagrant.primary_vm.channel.send(vagrant_method, @command) do |type, data|
        # type is one of [:stdout, :stderr, :exit_status]
        # data is a string for stdout/stderr and an int for exit status
            if type == :stdout
                listener.info data
            elsif type == :stderr
                listener.error data
            end
        end
        unless code == 0
            build.halt 'Command failed!'
        end
    end

    def perform_multi_vm(build, launcher, listener)
        @vagrant.vms.each do |name, vm|
            unless vm.state == :running
                build.halt "Vagrant VM #{name} doesn't appear to be running!"
            end

            listener.info("Running the command in Vagrant on VM #{name} with \"#{vagrant_method.to_s}\":")
            @command.split("\n").each do |line|
                listener.info("+ #{line}")
            end

            code = vm.channel.send(vagrant_method, @command) do |type, data|
            # type is one of [:stdout, :stderr, :exit_status]
            # data is a string for stdout/stderr and an int for exit status
                if type == :stdout
                    listener.info data
                elsif type == :stderr
                    listener.error data
                end
            end
            unless code == 0
                build.halt 'Command failed!'
            end
        end
    end
  end

  class UserBuilder < Jenkins::Tasks::Builder
    display_name "Execute shell script in Vagrant"

    include BaseBuilder

    attr_accessor :command

    def initialize(attrs)
      @command = attrs["command"]
    end

    def vagrant_method
      :execute
    end
  end

  class SudoBuilder < Jenkins::Tasks::Builder
    display_name "Execute shell script in Vagrant as admin"

    include BaseBuilder

    attr_accessor :command

    def initialize(attrs)
      @command = attrs["command"]
    end

    def vagrant_method
      :sudo
    end
  end

  class ProvisionBuilder < Jenkins::Tasks::Builder
    display_name 'Provision the Vagrant VM(s)'

    def initialize(attrs)
    end

    def prebuild(build, listener)
    end

    def perform(build, launcher, listener)
      @vagrant = build.env[:vagrant]
      if @vagrant.nil?
        build.halt "OH CRAP! I don't seem to have a Vagrant instance"
      end

      if @vagrant.multivm?
          @vagrant.vms.each do |name, vm|
              unless vm.state == :running
                  build.halt "Vagrant VM #{name} doesn't appear to be running!"
              end
              listener.info("Provisioning the Vagrant VM #{name}.. (this may take a while)")
              @vagrant.cli('provision', "#{name}")
          end
      else
        unless @vagrant.primary_vm.state == :running
            build.halt "Vagrant VM doesn't appear to be running!"
        end
        listener.info("Provisioning the Vagrant VM.. (this may take a while)")
        @vagrant.cli('provision')
      end
    end
  end
end
