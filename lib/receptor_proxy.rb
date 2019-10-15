require 'receptor_proxy/version'
require 'receptor_proxy/server'

# @example Simple rackup file for a local SSH connection
#    require 'purr'
#
#    # This middleware is to support optional logging
#    use Rack::Logger
#
#    run ReceptorProxy.server
#

module ReceptorProxy
  class << self
    # Creates or returns a singleton instance of the Rack-server
    def server
      @server ||= ::ReceptorProxy::Server.new
    end
  end
end
