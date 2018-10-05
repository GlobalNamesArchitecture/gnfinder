# frozen_string_literal: true

module Gnfinder
  # Gnfinder::Client connects to gnfinder server
  class Client
    def initialize(host = '0.0.0.0', port = '8778')
      @stub = Protob::GNFinder::Stub.new("#{host}:#{port}",
                                         :this_channel_is_insecure)
    end

    def ping
      @stub.ping(Protob::Void.new).value
    end

    def find_names(text, opts = {})
      raise 'Text cannot be empty' if text.to_s.strip == ''

      params = { text: text }
      params[:with_bayes] = true if opts[:with_bayes]
      params[:language] = opts[:language] if opts[:language].to_s.strip != ''

      @stub.find_names(Protob::Params.new(params)).names
    end
  end
end
