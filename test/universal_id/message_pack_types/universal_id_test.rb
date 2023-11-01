# frozen_string_literal: true

require_relative "../test_helper"

module UniversalID::MessagePackTypes
  class UniversalIDTest < Minitest::Test
    def test_universal_id
      with_persisted_campaign do |campaign|
        payload = {number: 123, string: "data", array: [1, 2, 3], hash: {model: campaign}}
        uid = UniversalID::URI::UID.create(payload)
        assert uid.valid?
        actual = MessagePack.unpack(MessagePack.pack(uid))
        assert_equal uid, actual
      end
    end
  end
end
