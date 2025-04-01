require "active_record/turntable/per_thread_registry"

module ActiveRecord::Turntable
  class SlaveRegistry
    if Util.ar71_or_later?
      extend ActiveRecord::Turntable::PerThreadRegistry
    else
      extend ActiveSupport::PerThreadRegistry
    end

    def initialize
      @registry = Hash.new { |h, k| h[k] = {} }
    end

    def slave_for(shard)
      @registry[shard][:current_slave]
    end

    def set_slave_for(shard, target_slave)
      @registry[shard][:current_slave] = target_slave
    end

    def clear_for!(shard)
      @registry[shard].clear
    end
  end
end
