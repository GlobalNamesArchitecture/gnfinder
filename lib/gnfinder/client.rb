# frozen_string_literal: true

module Gnfinder
  GNFINDER_MIN_VERSION = 'v0.9.0'

  # Gnfinder::Client connects to gnfinder server
  class Client
    def initialize(host = '0.0.0.0', port = '8778')
      @stub = Protob::GNFinder::Stub.new("#{host}:#{port}",
                                         :this_channel_is_insecure)
      return if gnfinder_version.version >= GNFINDER_MIN_VERSION

      raise 'gRPC server of gnfinder should be at least ' \
            ' #{GNFINDER_MIN_VERSION}.\n Download latest version from ' \
            'https://github.com/gnames/gnfinder/releases/latest.'
    end

    def gnfinder_version
      @stub.ver(Protob::Void.new)
    end

    def ping
      @stub.ping(Protob::Void.new).value
    end

    # rubocop:disable all
    def find_names(text, opts = {})
      raise 'Text cannot be empty' if text.to_s.strip == ''

      params = { text: text }
      params[:no_bayes] = true if opts[:no_bayes]
      params[:language] = opts[:language] if opts[:language].to_s.strip != ''
      if opts[:detect_language]
        params[:detect_language] = opts[:detect_language]
      end
      params[:verification] = true if opts[:verification]
      if opts[:sources] && !opts[:sources].empty?
        params[:sources] = opts[:sources]
      end

      @stub.find_names(Protob::Params.new(params))
    end
    # rubocop:enable all
  end
end
