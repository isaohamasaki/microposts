class AddOriginalUserIdToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :original_user_id, :integer
  end
end
