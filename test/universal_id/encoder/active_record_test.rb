# frozen_string_literal: true

require_relative "../../test_helper"

class UniversalID::Encoder::ActiveRecordTest < Minitest::Test
  def test_new_model
    campaign = Campaign.build_for_test
    encoded = UniversalID::Encoder.encode(campaign)
    expected = "G0QAAIyUqtsjPVl5TlKzKZpALGZjpKCBvwzJgkOO7KD2LaDmEdXYkpn7hLkDzVNFme8I9aQWSOwRNg"
    assert_equal expected, encoded

    decoded = UniversalID::Encoder.decode(encoded)
    assert_equal campaign.class, decoded.class
    refute_equal campaign.attributes, decoded.attributes
  end

  def test_new_model_include_unsaved_changes
    campaign = Campaign.build_for_test
    encoded = UniversalID::Encoder.encode(campaign, include_unsaved_changes: true)
    decoded = UniversalID::Encoder.decode(encoded)
    assert_equal campaign.class, decoded.class
    assert_equal campaign.attributes, decoded.attributes
  end

  def test_new_model_include_unsaved_changes_exclude_blanks
    campaign = Campaign.build_for_test
    encoded = UniversalID::Encoder.encode(campaign, include_unsaved_changes: true, include_blank: false)
    decoded = UniversalID::Encoder.decode(encoded)
    assert_equal campaign.class, decoded.class
    assert_equal campaign.attributes, decoded.attributes
  end

  def test_persisted_model
    campaign = Campaign.create_for_test
    encoded = UniversalID::Encoder.encode(campaign)
    decoded = UniversalID::Encoder.decode(encoded)
    assert_equal campaign, decoded
  end

  def test_changed_persisted_model
    campaign = Campaign.create_for_test
    campaign.description = "Changed Description"
    encoded = UniversalID::Encoder.encode(campaign)
    decoded = UniversalID::Encoder.decode(encoded)
    assert_equal campaign, decoded
    refute_equal campaign.description, decoded.description
  end

  def test_changed_persisted_model_include_unsaved_changes
    campaign = Campaign.create_for_test
    campaign.description = "Changed Description"
    encoded = UniversalID::Encoder.encode(campaign, include_unsaved_changes: true)
    decoded = UniversalID::Encoder.decode(encoded)
    assert_equal campaign, decoded
    assert_equal campaign.description, decoded.description
  end

  def test_changed_persisted_model_with_registered_custom_config
    yaml = <<~YAML
      prepack:
        exclude:
          - description
          - trigger
        include_blank: false

        database:
          include_unsaved_changes: true
          include_timestamps: false
    YAML

    _, settings = UniversalID::Settings.register("test_#{SecureRandom.alphanumeric(8)}", YAML.safe_load(yaml))

    campaign = Campaign.create_for_test
    # remember orig values
    description = campaign.description
    trigger = campaign.trigger

    # change values
    campaign.name = "Changed Name"
    campaign.description = "Changed Description"
    campaign.trigger = "Changed Trigger"

    encoded = UniversalID::Encoder.encode(campaign, **settings)
    decoded = UniversalID::Encoder.decode(encoded)

    # same record
    assert_equal campaign, decoded

    # included values match
    assert_equal campaign.name, decoded.name

    # excluded values do not match the in-memory changes
    refute_equal campaign.description, decoded.description
    refute_equal campaign.trigger, decoded.trigger

    # excluded values match the original values
    assert_equal description, decoded.description
    assert_equal trigger, decoded.trigger
  end
end
