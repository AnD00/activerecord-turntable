module ActiveRecord::Turntable
  class ConnectionProxy
    module Mixable
      extend ActiveSupport::Concern

      METHODS_REGEXP = /\A(insert|select|update|delete|exec_)/
      EXCLUDE_QUERY_REGEXP = /\A\s*(SHOW|SELECT\s+@@max_allowed_packet)/i
      QUERY_REGEXP = /\A\s*(INSERT|DELETE|UPDATE|SELECT)/i

      def mixable?(method, *args)
        query = args.first.to_s

        (method.to_s =~ METHODS_REGEXP && query !~ EXCLUDE_QUERY_REGEXP) ||
          (method.to_s == "execute" && query =~ QUERY_REGEXP && query !~ EXCLUDE_QUERY_REGEXP)
      end
    end
  end
end
