# Hacking on the Vagrant plugin

I highly recommend using [RVM](https://rvm.beginrescueend.com/) for this, my
local `.rvmrc` for this project, which will never be checked in is as follows:

    rvm use jruby@vagrant-plugin

This will make sure that I'm using the latest JRuby with a `vagrant-plugin`
gemset.


## Setting up your environment

You should really only need to run these two commands:

    % gem install bundler
    % bundle install

That should set up all the gems you need, which once installed you should be
able to run:

    % jpi server

Which will bring up Jenkins locally with the Vagrant plugin enabled.
