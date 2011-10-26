require 'rubygems'
require 'vagrant'


class VagrantBuilder < Jenkins::Tasks::Builder
  display_name "Execute shell script in Vagrant box"

  attr_accessor :command

  def initialize(attrs)
    puts "Initialize VagrantBuilder"
    p attrs
    @command = attrs["command"]
  end

  def prebuild(build, listener)
    build.env.each do |k, v|
      listener.info("#{k} = #{v}")
    end
    listener.info("BUILD VARS")
    build.build_var.each do |k, v|
      listener.info("#{k} = #{v}")
    end
  end

  def perform(build, launcher, listener)
    t = Tempfile.new("vagrant-shell")
    @command.split("\n").each do |line|
      t.write("#{line}\n")
    end
    t.flush

    listener.info("Checking my build variables: #{build.build_var.inspect}")
    listener.info("I should be running the following command: #{@command}")

    begin
      listener.info("Running shell script locally for now")
      launcher.execute("sh -xe #{t.path}", :chdir => "/", :out => listener)
    rescue
      raise
    ensure
      t.delete
    end
  end
end
