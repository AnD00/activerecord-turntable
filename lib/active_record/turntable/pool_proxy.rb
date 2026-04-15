module ActiveRecord::Turntable
  class PoolProxy
    def initialize(proxy)
      @proxy = proxy
    end

    attr_reader :proxy
    alias_method :connection, :proxy

    if Util.ar72_or_later?
      def with_connection(prevent_permanent_checkout: false)
        yield proxy
      end
    else
      def with_connection()
        yield proxy
      end
    end

    if Util.ar81_or_later?
      delegate :connected?, :checkout_timeout, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout=,
      :connections, :size, :max_connections, :min_connections, :max_age, :keepalive,
      :reaper, :schema_cache, :schema_cache=, :pool_config, :discarded?,
      :async_executor, :shard, :role, :schedule_query, :schema_reflection, :schema_reflection=, :server_version,
      :activated?, :maintainable?, :num_available_in_queue, :reaper_lock,
      :pool_transaction_isolation_level, :pool_transaction_isolation_level=,
      :with_pool_transaction_isolation_level, to: :proxy
    elsif Util.ar72_or_later?
      delegate :connected?, :checkout_timeout, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout=,
      :connections, :size, :reaper, :schema_cache, :schema_cache=, :pool_config, :connection_klass, :discarded?,
      :connection_class, :async_executor, :shard, :role, :schedule_query, :schema_reflection, :schema_reflection=, :server_version, to: :proxy
    elsif Util.ar71_or_later?
      delegate :connected?, :checkout_timeout, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout, :checkout_timeout=,
      :connections, :size, :reaper, :schema_cache, :schema_cache=, :pool_config, :connection_klass, :discarded?,
      :connection_class, :async_executor, :shard, :role, :schedule_query, :schema_reflection, :schema_reflection=, to: :proxy
    elsif Util.ar70_or_later?
      delegate :connected?, :checkout_timeout, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout, :checkout_timeout=,
      :connections, :size, :reaper, :schema_cache, :schema_cache=, :pool_config, :connection_klass, :discarded?,
      :connection_class, :async_executor, :shard, :role, :schedule_query, to: :proxy
    elsif Util.ar61_or_later?
      delegate :connected?, :checkout_timeout, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout, :checkout_timeout=, :dead_connection_timeout,
      :connections, :size, :reaper, :table_exists?, :query_cache_enabled, :enable_query_cache!, :disable_query_cache!, :schema_cache, :schema_cache=, 
      :db_config, :pool_config, :connection_klass, :discarded?, :owner_name, to: :proxy
    else
      delegate :connected?, :checkout_timeout, :automatic_reconnect, :automatic_reconnect=, :checkout_timeout, :checkout_timeout=, :dead_connection_timeout,
      :spec, :connections, :size, :reaper, :table_exists?, :query_cache_enabled, :enable_query_cache!, :disable_query_cache!, :schema_cache, :schema_cache=, to: :proxy
    end

    %w(columns_hash column_defaults primary_keys db_config).each do |name|
      define_method(name.to_sym) do
        @proxy.send(name.to_sym)
      end
    end

    %w(table_exists? columns).each do |name|
      define_method(name.to_sym) do |*args|
        @proxy.send(name.to_sym, *args)
      end
    end

    if Util.ar80_or_later?
      def connection_descriptor
        proxy.default_shard.connection_pool.connection_descriptor
      end
    end

    def active_connection?
      connection_pools_list.any?(&:active_connection?)
    end

    if Util.ar72_or_later?
      def lease_connection
        proxy
      end

      def disable_query_cache(dirties: true, &block)
        connection_pools_list.each do |pool|
          pool.lease_connection.disable_query_cache!
        end
        yield
      end

      def clear_query_cache
        connection_pools_list.each do |pool|
          pool.lease_connection.clear_query_cache
        end
      end
    end

    if Util.ar81_or_later?
      %w[activate recycle! prepopulate preconnect].each do |name|
        define_method(name.to_sym) do
          connection_pools_list.each { |cp| cp.public_send(name.to_sym) }
        end
      end

      %w[retire_old_connections keep_alive].each do |name|
        define_method(name.to_sym) do |*args|
          connection_pools_list.each { |cp| cp.public_send(name.to_sym, *args) }
        end
      end
    end

    %w[
      clear_active_connections!
      clear_all_connections!
      clear_reloadable_connections!
      clear_stale_cached_connections!
      disconnect
      disconnect!
      flush!
      reap
      release_connection
      verify_active_connections!
      permanent_lease?
    ].each do |name|
      define_method(name.to_sym) do
        connection_pools_list.each { |cp| cp.public_send(name.to_sym) }
      end
    end

    %w[
      clear_reloadable_connections
      flush
    ].each do |name|
      define_method(name.to_sym) do |args|
        connection_pools_list.each { |cp| cp.public_send(name.to_sym, *args) }
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
