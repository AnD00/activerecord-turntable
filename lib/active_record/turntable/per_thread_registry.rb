# frozen_string_literal: true
require "active_support/core_ext/module/delegation"

module ActiveRecord::Turntable
  module PerThreadRegistry
    def self.extended(object)
      object.instance_variable_set :@per_thread_registry_key, object.name.freeze
    end

    def instance
      Thread.current[@per_thread_registry_key] ||= new
    end

    private
      def method_missing(name, *args, &block)
        singleton_class.delegate name, to: :instance

        send(name, *args, &block)
      end
      ruby2_keywords(:method_missing)
  end
end