require File.join(File.dirname(__FILE__), 'lib', 'dynamic_liquid_templates')
require File.join(File.dirname(__FILE__), 'lib', 'database_file_system')
ActionController::Base.send(:include, DynamicLiquidTemplates)