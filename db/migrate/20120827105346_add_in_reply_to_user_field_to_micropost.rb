class AddInReplyToUserFieldToMicropost < ActiveRecord::Migration
  def change
    add_column :microposts, :in_reply_to_id, :integer
    add_column :microposts, :in_reply_length, :integer
  end
end
