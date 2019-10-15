lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# This file is used by Rack-based servers to start the application.
require 'receptor_proxy'
require "bundler/setup"

# This middleware is to support optional logging
use Rack::Logger

run ReceptorProxy.server
