# frozen_string_literal: true

require_relative "test_helper"

class UniversalID::EncoderTest < Minitest::Test
  def test_new_model
    with_new_campaign do |campaign|
      encoded = UniversalID::Encoder.encode(campaign)
      decoded = UniversalID::Encoder.decode(encoded)
      assert_equal campaign.attributes, decoded.attributes
    end
  end

  def test_persisted_model_without_changes
    with_persisted_campaign do |campaign|
      encoded = UniversalID::Encoder.encode(campaign)
      decoded = UniversalID::Encoder.decode(encoded)
      assert_equal campaign.attributes, decoded.attributes
    end
  end

  def test_persisted_model_with_changes_keep_changes
    with_persisted_campaign do |campaign|
      campaign.name = "Changed Name"
      assert campaign.changed?
      encoded = UniversalID::Encoder.encode(campaign, active_record: {keep_changes: true})
      decoded = UniversalID::Encoder.decode(encoded)
      assert_equal campaign.attributes, decoded.attributes
    end
  end

  def test_persisted_model_with_changes_discard_changes
    with_persisted_campaign do |campaign|
      campaign.name = "Changed Name"
      assert campaign.changed?
      encoded = UniversalID::Encoder.encode(campaign, active_record: {keep_changes: false})
      decoded = UniversalID::Encoder.decode(encoded)
      refute_equal campaign.attributes, decoded.attributes
    end
  end
end
