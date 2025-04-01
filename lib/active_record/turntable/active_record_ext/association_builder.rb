require "active_record/associations/builder/association"

module ActiveRecord::Turntable
  module ActiveRecordExt
    module AssociationBuilder
      $VERBOSE = nil
      ActiveRecord::Associations::Builder::Association::VALID_OPTIONS = [
        :class_name, :anonymous_class, :primary_key, :foreign_key, :dependent, :validate, :inverse_of, :strict_loading, :foreign_shard_key
      ].freeze
      $VERBOSE = true
    end
  end
end
