class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.string :email
      t.string :name
      t.integer :subscriber_list_id
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :subscribers
  end
end
