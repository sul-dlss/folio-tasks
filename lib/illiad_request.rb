# frozen_string_literal: true

require 'config'
require 'http'
Config.load_and_set_settings(Config.setting_files('config', ENV['STAGE'] || 'dev'))

# Class to post user data to FOLIO Users module
class IlliadRequest
  DEFAULT_HEADERS = {
    'ApiKey' => Settings.illiad_api_key,
    'accept' => 'application/json; version=1',
    'content_type' => 'application/json'
  }.freeze

  def post(path, json, **other)
    parse(authenticated_request(path, method: :post, body: json), **other)
  end

  def parse(response, **other)
    if other[:response_code]
      response.code
    else
      pp JSON.parse(response)
    end
  rescue JSON::ParserError
    puts response
  end

  def authenticated_request(path, headers: {}, method: :get, **other)
    HTTP
      .headers(DEFAULT_HEADERS.merge(headers))
      .request(method, base_url + path, **other)
  end

  def base_url
    Settings.sul_illiad
  end
end
