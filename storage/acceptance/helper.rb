require "google/cloud/kms"
require "google/cloud/storage"
require "httparty"
require "minitest/autorun"
require "securerandom"

def delete_bucket bucket_name
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name
  if bucket
    bucket.files.each &:delete
    bucket.delete
  end
end

def get_kms_key project_id
  kms_client = Google::Cloud::Kms.new

  key_ring_id = "gapic_test_ring_id"
  location_path = kms_client.location_path project_id, "us"
  key_ring_path = kms_client.key_ring_path project_id, "us", key_ring_id
  begin
    key_ring = kms_client.create_key_ring location_path, key_ring_id, {}
  rescue Google::Gax::GaxError
    key_ring = kms_client.get_key_ring key_ring_path
  end

  crypto_key_id = "gapic_test_key"
  crypto_key = {
    purpose: :ENCRYPT_DECRYPT
  }
  crypto_key_path = kms_client.crypto_key_path project_id, "us", key_ring_id, crypto_key_id
  begin
    kms_client.create_crypto_key(key_ring_id, crypto_key_id, crypto_key).name
  rescue Google::Gax::GaxError
    kms_client.get_crypto_key(crypto_key_path).name
  end
end
