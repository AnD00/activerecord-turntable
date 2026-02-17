class UserProfile < ActiveRecord::Base
  # shard by other key
  turntable :user_cluster, :user_id
  sequencer :user_seq
  belongs_to :user
  # https://github.com/rails/rails/pull/47463
  serialize :data, coder: JSON
end
