module ActiveRecord::Turntable
  class Mixer
    class Fader
      class SpecifiedShard < Fader
        def execute
          shard, query = @shards_query_hash.first
          @proxy.with_shard(shard) do
            hashes, positional_args = @args.partition { |arg| arg.is_a?(Hash) }
            kwargs = hashes.reduce({}, :merge)
            shard.connection.send(@called_method, query, *positional_args, **kwargs, &@block)
          end
        end
      end
    end
  end
end
