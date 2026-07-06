module PhotoStore
  # Central database registry managing technical metadata sheets for master files.
  class Store
    def initialize
      @records = {}
    end

    # Registers a pre-computed photo record into the store cache.
    # @param record [Flatplan::Model::PhotoRecord] technical dossier
    def register(record)
      @records[record.image_key] = record
    end

    # Queries technical metrics using the unique image key descriptor.
    # @param image_key [String] e.g., "DP2Q2173"
    # @return [Flatplan::Model::PhotoRecord, nil]
    def find(image_key)
      @records[image_key]
    end
  end
end
