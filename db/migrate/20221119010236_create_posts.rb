class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :content
      t.integer :num_views, default: 0

      t.timestamps
    end
  end
end
