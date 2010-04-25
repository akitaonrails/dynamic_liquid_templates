class CreateDynamicTemplates < ActiveRecord::Migration
  def self.up
    create_table :dynamic_templates do |t|
      t.string :path
      t.text :body
      t.string :scope, :limit => 32

      t.timestamps
    end
    add_index :dynamic_templates, :path
    add_index :dynamic_templates, [:path, :scope]
  end

  def self.down
    remove_index :dynamic_templates, :path
    remove_index :dynamic_templates, [:path, :scope]
    drop_table :dynamic_templates
  end
end
