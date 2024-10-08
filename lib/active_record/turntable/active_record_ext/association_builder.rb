require "active_record/associations/builder/association"

module ActiveRecord::Turntable
  module ActiveRecordExt
    module AssociationBuilder
      if ActiveRecord::Associations::Builder::Association.const_defined?(:VALID_OPTIONS)
        ActiveRecord::Associations::Builder::Association.send(:remove_const, :VALID_OPTIONS)
      end

      ActiveRecord::Associations::Builder::Association::VALID_OPTIONS = [
        :class_name, :anonymous_class, :primary_key, :foreign_key, :dependent, :validate, :inverse_of, :strict_loading, :foreign_shard_key
      ].freeze
    end
  end
end
