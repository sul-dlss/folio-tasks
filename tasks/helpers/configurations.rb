# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by configurations rake tasks
module ConfigurationsTaskHelpers
  include FolioRequestHelper

  def pull_configurations(config)
    hash = @@folio_request.get("/configurations/entries?query=module==#{config}&limit=50")
    trim_hash(hash, 'configs')
    hash.to_json
  end

  def load_configs
    Settings.configurations.each do |config|
      config_entry_json("#{Settings.json}/configurations/#{config}.json")['configs'].each do |obj|
        config_entry_post(obj)
      end
    end
  end

  def update_configs
    Settings.configurations.each do |config|
      config_entry_json("#{Settings.json}/configurations/#{config}.json")['configs'].each do |obj|
        config_entry_put(obj)
      end
    end
  end

  def load_module_configs(config)
    config_entry_json("#{Settings.json}/configurations/#{config}.json")['configs'].each do |obj|
      config_entry_post(obj)
    end
  end

  def update_module_configs(config)
    config_entry_json("#{Settings.json}/configurations/#{config}.json")['configs'].each do |obj|
      config_entry_put(obj)
    end
  end

  def config_entry_json(file)
    JSON.parse(File.read(file))
  end

  def config_entry_post(hash)
    @@folio_request.post('/configurations/entries', hash.to_json)
  end

  def config_entry_put(hash)
    @@folio_request.put("/configurations/entries/#{hash['id']}", hash.to_json)
  end

  def config_entry_delete(id)
    @@folio_request.delete("/configurations/entries/#{id}")
  end

  def sip2_service_points
    JSON.parse(File.read("#{Settings.json}/configurations/sip2_service_points.json"))
  end

  def sip2_service_point_ids(servicepoint)
    @@folio_request.get_cql('/service-points', "code=#{servicepoint}")['servicepoints'][0]['id']
  end

  def sip2_config_json(servicepoint)
    config = File.read("#{Settings.json}/configurations/self_checkout_config.json")
    config.gsub('SERVICE_POINT_ID', servicepoint)
  end

  def sip2_config_post(servicepoint)
    @@folio_request.post('/configurations/entries', servicepoint)
  end

  def email_configuration
    JSON.parse(File.read("#{Settings.json}/configurations/email_config.json"))
  end

  def email_config_post(hash)
    hash['value'] = "mail.#{Settings.namespace}.svc.cluster.local"
    @@folio_request.post('/smtp-configuration', hash.to_json)
  end

  def pull_email_config
    hash = @@folio_request.get('/smtp-configuration')
    trim_hash(hash, 'smtpConfigurations')
    hash.to_json
  end
end
