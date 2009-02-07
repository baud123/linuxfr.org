class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.string :state, :null => false, :default => 'draft'
      t.string :title
      t.text :body
      t.text :second_part
      t.references :section
      t.timestamps
    end
  end

  def self.down
    drop_table :news
  end
end