module Gnfinder
  # Gnfinder::Client connects to gnfinder server
  class Client
    def initialize(host = '0.0.0.0', port = '8778', opts = {})
      @opts = opts
      @stub = Protob::GNFinder::Stub.new("#{host}:#{port}",
                                         :this_channel_is_insecure)
    end

    def ping
      @stub.ping(Protob::Void.new).value
    end
  end
end
