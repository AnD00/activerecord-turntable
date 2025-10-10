module ActiveRecord::Turntable
  class Mixer
    class Fader
      class CalculateShardsSumResult < Fader
        def execute
          results = @shards_query_hash.map do |shard, query|
            args = @args.dup
            args[1] = args[1].dup if args[1].present?
            hashes, positional_args = @args.partition { |arg| arg.is_a?(Hash) }
            kwargs = hashes.reduce({}, :merge)
            shard.connection.send(@called_method, query, *positional_args, **kwargs, &@block)
          end
          merge_results(results)
        end

        private

          def merge_results(results)
            ActiveRecord::Result.new(
              results.first.columns,
              results[0].rows.zip(*results[1..-1].map(&:rows)).map { |r| [r.map(&:first).inject(&:+)] },
              results.first.column_types
            )
          end
      end
    end
  end
end
