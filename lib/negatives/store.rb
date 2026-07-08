require_relative 'builder'

module Negatives
  # Central database registry managing technical metadata sheets for master files.
  class Store
    def initialize
      @store = Builder.call
    end

    # Queries technical metrics using the unique image key descriptor.
    # @param key [String/Symbol] e.g., "DP2Q2173"
    # @return [Flatplan::Model::PhotoRecord, nil]
    def get(key)
      @store[key.to_sym]
    end

    # @param keys [Array<String/Symbol] requested keys
    # @returns [Hash] containing the entries for the given keys
    def slice(*keys)
      @store.slice( *keys.map(&:to_sym) )
    end
  end
end
