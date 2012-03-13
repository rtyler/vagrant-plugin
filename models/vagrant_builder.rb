require 'rubygems'
require 'vagrant'


class BaseVagrantBuilder < Jenkins::Tasks::Builder
  attr_accessor :command

  def initialize(attrs)
    @command = attrs["command"]
  end

  def prebuild(build, listener)
  end

  def perform(build, launcher, listener)
    # This should be set by the VagrantWrapper
    @vagrant = build.env[:vagrant]

    if @vagrant.nil?
      build.halt "OH CRAP! I don't seem to have a Vagrant instance!"
    end

    unless @vagrant.primary_vm.state == :running
      build.halt 'Vagrant VM doesn\'t appear to be running!'
    end

    listener.info "Running the command in Vagrant with \"#{vagrant_method.to_s}\": #{@command}"

    unless @vagrant.nil?
      code = @vagrant.primary_vm.channel.send(vagrant_method, @command) do |type, data|
        # type is one of [:stdout, :stderr, :exit_status]
    #   # data is a string for stdout/stderr and an int for exit status
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

class VagrantUserBuilder < BaseVagrantBuilder
  display_name "Execute shell script in Vagrant"

  def vagrant_method
    :execute
  end
end

class VagrantSudoBuilder < BaseVagrantBuilder
  display_name "Execute shell script in Vagrant as admin"

  def vagrant_method
    :sudo
  end
end

class VagrantProvisionBuilder < Jenkins::Tasks::Builder
  display_name 'Provision the Vagrant machine'

  def perform(build, launcher, listener)
    @vagrant = build.env[:vagrant]
    if @vagrant.nil?
      built.halt "OH CRAP! I don't seem to have a Vagrant instance"
    end

    unless @vagrant.primary_vm.state == :running
      build.halt 'Vagrant VM doesn\'t appear to be running!'
    end

    @vagrant.cli('provision')
  end
end
