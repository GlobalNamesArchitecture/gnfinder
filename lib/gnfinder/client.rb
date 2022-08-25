# frozen_string_literal: true

module Gnfinder
  # Gnfinder::Client connects to gnfinder server
  class Client
    def initialize(host = 'https://gnfinder.globalnames.org', port = '')
      api_path = '/api/v1'
      url = host + api_path
      url = "#{host}:#{port}#{api_path}" if port.to_s != ''
      @site = RestClient::Resource.new(url, read_timeout: 60)
      @port = port
    end

    def gnfinder_version
      resp = @site['/version'].get
      ver = JSON.parse(resp.body, symbolize_names: true)
      OpenStruct.new(ver)
    end

    def ping
      @site['/ping'].get.body
    end

    def find_file(path, opts = {})
      params = {}
      update_params(params, opts)
      file = File.new(path, 'rb')
      params = params.merge(file: file)
      resp = @site['find'].post(params)
      prepare_result(resp)
    end

    def find_url(url, opts = {})
      return to_open_struct({ "names": [] }) if url.to_s.strip == ''

      params = { url: url }
      find(params, opts)
    end

    def find_names(text, opts = {})
      return to_open_struct({ "names": [] }) if text.to_s.strip == ''

      params = { text: text }
      find(params, opts)
    end

    private

    # rubocop:disable all
    def find(params, opts = {})
      update_params(params, opts)

      resp = @site['find'].post params.to_json, {content_type: :json, accept: :json}
      prepare_result(resp)
    end
    # rubocop:enable all

    def prepare_result(response)
      output = JSON.parse(response.body)
      res = output['metadata']
      res['names'] = output['names'] || []
      res = res.deep_transform_keys(&:underscore)
      res['names'] = [] if res['names'].nil?
      to_open_struct(res)
    end

    # rubocop:disable all
    def update_params(params, opts)
      params[:noBayes] = true if opts[:no_bayes]
      params[:oddsDetails] = true if opts[:odds_details]
      params[:language] = opts[:language] if opts[:language].to_s.strip != ''

      params[:wordsAround] = opts[:words_around] if opts[:words_around] && opts[:words_around].positive?

      params[:verification] = true if opts[:verification]

      params[:sources] = opts[:sources] if opts[:sources] && !opts[:sources].empty?
    end
    # rubocop:enable all

    def to_open_struct(obj)
      case obj
      when Hash
        OpenStruct.new(obj.transform_values { |val| to_open_struct(val) })
      when Array
        obj.map { |o| to_open_struct(o) }
      else # Assumed to be a primitive value
        obj
      end
    end
  end
end
