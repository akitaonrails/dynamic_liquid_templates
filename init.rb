require File.join(File.dirname(__FILE__), 'lib', 'dynamic_liquid_templates')
ActionController::Base.send(:include, DynamicLiquidTemplates)