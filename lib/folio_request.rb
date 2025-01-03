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
    path += "?query=#{CGI.escape(query)}"
    parse(authenticated_request(path))
  end

  def get_cql_json(path, limit, query)
    path += "?limit=#{limit}&query=#{CGI.escape(query)}"
    puts JSON.pretty_generate(JSON.parse(authenticated_request(path)))
  end

  def post_no_body(path)
    parse(authenticated_request(path, method: :post))
  end

  def post(path, json, **other)
    parse(authenticated_request(path, method: :post, body: json), **other)
  end

  def put(path, json, **other)
    parse(authenticated_request(path, method: :put, body: json), **other)
  end

  def delete(path, **other)
    parse(authenticated_request(path, method: :delete), **other)
  end

  def parse(response, **other)
    if other[:response_code]
      response.code
    elsif other[:no_response]
      ''
    else
      pp JSON.parse(response)
    end
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
      .timeout(150)
      .headers(default_headers.merge(headers))
      .request(method, base_url + path, **other)
  end

  def base_url
    Settings.okapi.url
  end

  def make_path(path)
    path = path.gsub(/\s/, '%20')
    path.start_with?('/') ? path.strip : "/#{path.strip}"
  end

  def default_headers
    DEFAULT_HEADERS.merge(Settings.okapi.headers || {})
  end
end
