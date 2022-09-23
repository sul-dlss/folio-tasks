# frozen_string_literal: true

require 'config'
require 'http'
Config.load_and_set_settings(Config.setting_files('config', ENV['STAGE'] || 'dev'))

# Class to post user data to FOLIO Users module
class FolioRequest
  DEFAULT_HEADERS = {
    accept: 'application/json, text/plain',
    content_type: 'application/json'
  }.freeze

  def get(path)
    parse(authenticated_request(path))
  end

  def get_json(path)
    puts JSON.pretty_generate(JSON.parse(authenticated_request(path)))
  end

  def get_cql(path, query)
    path += "?query=#{query}"
    parse(authenticated_request(path))
  end

  def get_cql_json(path, query)
    path += "?query=#{query}"
    puts JSON.pretty_generate(JSON.parse(authenticated_request(path)))
  end

  def post_no_body(path)
    parse(authenticated_request(path, method: :post))
  end

  def post(path, json)
    parse(authenticated_request(path, method: :post, body: json))
  end

  def put(path, json)
    parse(authenticated_request(path, method: :put, body: json))
  end

  def delete(path)
    parse(authenticated_request(path, method: :delete))
  end

  def parse(response)
    pp JSON.parse(response)
  rescue JSON::ParserError
    puts response
  end

  def session_token
    @session_token ||= begin
      response = request('/authn/login', json: Settings.okapi.login_params, method: :post)
      response['x-okapi-token']
    end
  end

  def authenticated_request(path, headers: {}, **other)
    request(path, headers: headers.merge('x-okapi-token': session_token), **other)
  end

  def request(path, headers: {}, method: :get, **other)
    HTTP
      .headers(default_headers.merge(headers))
      .request(method, base_url + path, **other)
  end

  def base_url
    Settings.okapi.url
  end

  def default_headers
    DEFAULT_HEADERS.merge(Settings.okapi.headers || {})
  end
end
