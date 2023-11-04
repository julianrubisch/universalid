# frozen_string_literal: true

require_relative "configurable"

class UniversalID::GlobalIDIdentificationPacker
  extend Forwardable
  include UniversalID::GlobalIDConfigurable

  class << self
    def config
      @config ||= ::UniversalID.config.message_pack.global_id
    end
  end

  def_delegators :"self.class", :config
  attr_reader :object

  def initialize(object = nil)
    @object = object
  end

  # Packs the object using a MessagePack::Packer
  def pack_with(packer)
    hash = object.public_send(config.prepack_method)
    packer.write object.class.name
    packer.write prepare_for_packing(hash)
  end

  private

  # Prepares a hash representation of the object for packing
  def prepare_for_packing(hash = {})
    hash.each_with_object({}) do |(key, val), memo|
      key = key.to_s
      next if excludes[key]
      next if !includes.empty? && includes[key]
      next if exclude_blank? && val.nil? || val.respond_to?(:empty?) && val.empty?
      memo[key] = val.is_a?(::Hash) ? prepare_for_packing(val) : val
    end
  end
end
