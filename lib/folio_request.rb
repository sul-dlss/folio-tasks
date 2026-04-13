# frozen_string_literal: true

require 'folio_client'
require 'config'
require 'http'
Config.load_and_set_settings(Config.setting_files('config', ENV['STAGE'] || 'dev'))

# Class to use HTTP actions with FOLIO
class FolioRequest
  def client
    FolioClient.configure(
      url: Settings.okapi.url,
      login_params: Settings.okapi.login_params,
      tenant_id: Settings.okapi.tenant_id,
      user_agent: Settings.okapi.user_agent
    )
  end

  def get(path)
    response = client.get(path)
    pp response unless response.nil?
  end

  def get_json(path)
    puts JSON.pretty_generate(client.get(path))
  end

  def get_cql(path, query)
    path += "?query=#{CGI.escape(query)}"
    response = client.get(path)
    pp response unless response.nil?
  end

  def get_cql_json(path, limit, query)
    path += "?limit=#{limit}&query=#{CGI.escape(query)}"
    puts JSON.pretty_generate(client.get(path))
  end

  def post(path, json = nil)
    response = client.post(path, json)
    pp response unless response.nil?
  end

  def put(path, json = nil)
    response = client.put(path, json)
    pp response unless response.nil?
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
      response.parse(:json)['okapiToken']
    end
  end

  def authenticated_request(path, headers: {}, **other)
    request(path, headers: headers.merge('x-okapi-token': session_token), **other)
  end

  def request(path, headers: {}, method: :get, **other)
    default_headers = {
      accept: 'application/json, text/plain',
      content_type: 'application/json',
      user_agent: Settings.okapi.user_agent,
      'x-okapi-tenant': Settings.okapi.tenant_id
    }
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
end
