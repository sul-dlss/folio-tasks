# frozen_string_literal: true

require 'folio_client'
require 'config'
require 'http'
Config.load_and_set_settings(Config.setting_files('config', ENV['STAGE'] || 'dev'))

# Class to use FolioClient actions with FOLIO
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
    handle_folio_request do
      pp client.get(path)
    end
  end

  def get_json(path)
    handle_folio_request do
      puts JSON.pretty_generate(client.get(path))
    end
  end

  def get_cql(path, query)
    path += "?query=#{CGI.escape(query)}"
    handle_folio_request do
      pp client.get(path)
    end
  end

  def get_cql_json(path, limit, query)
    path += "?limit=#{limit}&query=#{CGI.escape(query)}"
    handle_folio_request do
      puts JSON.pretty_generate(client.get(path))
    end
  end

  def post(path, json = nil, **other)
    handle_folio_request do
      client.post(path, json) do |resp|
        parse(resp, **other)
      end
    end
  end

  def put(path, json = nil, **other)
    handle_folio_request do
      client.put(path, json) do |resp|
        parse(resp, **other)
      end
    end
  end

  def delete(path, **other)
    handle_folio_request do
      client.delete(path) do |resp|
        parse(resp, **other)
      end
    end
  end

  def handle_folio_request
    yield
  rescue FolioClient::Error => e
    puts "FolioClient Error: #{e.message}"
    nil
  end

  def parse(response, **other)
    if other[:response_code]
      puts response.status
    elsif other[:no_response]
      ''
    else
      pp JSON.parse(response.body) unless response.body.empty?
    end
  rescue JSON::ParserError
    puts response
  end

  def make_path(path)
    path = path.gsub(/\s/, '%20')
    path.start_with?('/') ? path.strip : "/#{path.strip}"
  end
end
