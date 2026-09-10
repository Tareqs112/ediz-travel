require "test_helper"

class ActiveStorageR2ConfigTest < ActiveSupport::TestCase
  test "cloudflare R2 service configuration correctly disables aggressive checksums" do
    # ActiveStorage parses storage.yml into Rails.configuration.active_storage.service_configurations
    # But for a basic test, we can just load the YAML safely.
    yaml_config = YAML.load(ERB.new(File.read(Rails.root.join("config", "storage.yml"))).result)
    cloudflare_config = yaml_config["cloudflare"]
    
    assert_not_nil cloudflare_config, "Cloudflare config should exist in storage.yml"
    assert_equal "S3", cloudflare_config["service"]
    assert_equal "when_required", cloudflare_config["request_checksum_calculation"]
    assert_equal "when_required", cloudflare_config["response_checksum_validation"]
    
    assert_nothing_raised do
      Aws::S3::Client.new(
        region: "auto",
        endpoint: "https://test.r2.cloudflarestorage.com",
        access_key_id: "test",
        secret_access_key: "test",
        request_checksum_calculation: cloudflare_config["request_checksum_calculation"],
        response_checksum_validation: cloudflare_config["response_checksum_validation"]
      )
    end
  end
end
