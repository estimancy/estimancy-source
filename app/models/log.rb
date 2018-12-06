class Log < ActiveRecord::Base
  attr_accessible :after, :before, :event, :item_id, :item_type, :user_id, :transaction_id

  serialize :after
  serialize :before
end
