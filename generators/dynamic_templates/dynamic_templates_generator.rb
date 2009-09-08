class DynamicTemplatesGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'app/models'
      m.template 'model.rb', 'app/models/dynamic_template.rb'
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_dynamic_templates"
    end
  end
  
  protected
  
  def banner
    "Usage: #{$0} dynamic_templates"
  end
end