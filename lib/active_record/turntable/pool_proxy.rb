module ActiveRecord::Turntable
  class PoolProxy
    def initialize(proxy)
      @proxy = proxy
    end

    attr_reader :proxy
    alias_method :connection, :proxy

    def with_connection
      yield proxy
    end

    delegate :connected?, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout, :dead_connection_timeout,
             :spec, :connections, :size, :reaper, :table_exists?, :query_cache_enabled, :enable_query_cache!, to: :proxy

    %w(columns_hash column_defaults primary_keys).each do |name|
      define_method(name.to_sym) do
        @proxy.send(name.to_sym)
      end
    end

    %w(table_exists? columns).each do |name|
      define_method(name.to_sym) do |*args|
        @proxy.send(name.to_sym, *args)
      end
    end

    def active_connection?
      connection_pools_list.any?(&:active_connection?)
    end

    %w(disconnect!
       release_connection
       clear_all_connections!
       clear_active_connections!
       clear_reloadable_connections!
       clear_stale_cached_connections!
       verify_active_connections!).each do |name|
      define_method(name.to_sym) do
        connection_pools_list.each { |cp| cp.public_send(name.to_sym) }
      end
    end

    def discard!
      # Nothing to do
    end

    private

      def connection_pools_list
        pools = []
        pools << proxy.default_shard.connection_pool
        if proxy.respond_to?(:sequencers)
          pools.concat proxy.cluster.sequencers.values.map { |s| s.try(:connection_pool) }.compact
        end
        pools.concat(proxy.cluster.shards.map(&:connection_pool))
        pools.compact
      end
  end
end
