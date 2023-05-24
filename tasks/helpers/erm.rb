# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by e-usage rake tasks
module ErmTaskHelpers
  include FolioRequestHelper

  def data_providers_tsv
    CSV.parse(File.open("#{Settings.tsv}/erm/e-usage-data-providers.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def data_providers_hash(obj)
    {
      'label' => obj['label'],
      'harvestingConfig' => harvesting_configs(obj),
      'sushiCredentials' => sushi_credentials(obj)
    }
  end

  def harvesting_configs(obj)
    {
      'harvestingStatus' => obj['harvestingStatus'],
      'harvestVia' => obj['harvestVia'],
      'reportRelease' => obj['reportRelease'].to_i,
      'requestedReports' => [obj['requestedReports']],
      'sushiConfig' => sushi_configs(obj)
    }
  end

  def sushi_configs(obj)
    {
      'serviceType' => obj['serviceType'],
      'serviceUrl' => obj['serviceUrl']
    }
  end

  def sushi_credentials(obj)
    {
      'customerId' => obj['customerId'],
      'requestorId' => obj['requestorId'],
      'apiKey' => obj['apiKey']
    }
  end

  def data_providers_post(obj)
    @@folio_request.post('/usage-data-providers', obj.to_json)
  end
end
