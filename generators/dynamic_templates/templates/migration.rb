class CreateDynamicTemplates < ActiveRecord::Migration
  def self.up
    create_table :dynamic_templates do |t|
      t.string :path
      t.text :body

      t.timestamps
    end
    add_index :dynamic_templates, :path
  end

  def self.down
    remove_index :dynamic_templates, :path
    drop_table :dynamic_templates
  end
end
