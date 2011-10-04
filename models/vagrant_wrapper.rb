
class VagrantWrapper < Jenkins::Tasks::BuildWrapper

  display_name "Vagrant Build Wrapper"

  # Called some time before the build is to start.
  def setup(build, launcher, listener, env)
    listener.info "build will start"
  end

  # Called some time when the build is finished.
  def teardown(build, listener, env)
    listener.info "build finished"
  end

end
