module ActiveRecord::Turntable
  class Mixer
    class Fader
      class SelectShardsMergeResult < Fader
        def execute
          results = @shards_query_hash.map do |shard, query|
            args = @args.dup
            args[1] = args[1].dup if args[1].present?
            hashes, positional_args = args.partition { |arg| arg.is_a?(Hash) }
            kwargs = hashes.reduce({}, :merge)
            shard.connection.send(@called_method, query, *positional_args, **kwargs, &@block)
          end
          merge_results(results)
        end

        private

          def merge_results(results)
            if results.any? { |r| r.is_a?(ActiveRecord::Result) }
              first_result = results.find(&:present?)
              return results.first unless first_result

              ActiveRecord::Result.new(
                first_result.columns,
                results.flat_map(&:rows),
                first_result.column_types
              )
            else
              results.compact.inject(&:+)
            end
          end
      end
    end
  end
end
