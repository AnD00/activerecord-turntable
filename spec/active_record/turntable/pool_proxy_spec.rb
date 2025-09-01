require "spec_helper"

describe ActiveRecord::Turntable::PoolProxy do
  context "When initialized" do
    subject { ActiveRecord::Turntable::PoolProxy.new(nil) }

    UNSUPPORTED_PROXY_METHODS = %i[checkout checkin stat lock_thread= remove num_waiting_in_queue
                                   migration_context permanent_lease? migrations_paths pin_connection!
                                   unpin_connection! schema_migration internal_metadata active_connection].freeze

    context "Comparing original connection pool" do
      (ActiveRecord::ConnectionAdapters::ConnectionPool.instance_methods(false) - UNSUPPORTED_PROXY_METHODS).each do |original_method|
        it { is_expected.to be_respond_to(original_method) }
      end
    end
  end
end
