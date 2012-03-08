require 'rubygems'
require 'vagrant'


class BaseVagrantBuilder < Jenkins::Tasks::Builder
  attr_accessor :command

  def initialize(attrs)
    @command = attrs["command"]
    @vagrant = nil
  end

  def prebuild(build, listener)
  end

  def perform(build, launcher, listener)
    @vagrant = Vagrant::Environment.new(:cwd => build.workspace.to_s)
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
