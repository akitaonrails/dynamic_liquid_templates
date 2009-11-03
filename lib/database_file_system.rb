module DynamicLiquidTemplates
  # Liquid::Template.file_system = Liquid::DatabaseFileSystem.new(template_path)
  # liquid = Liquid::Template.parse(template)
  #
  # == Liquid Includes
  # 
  # Example for a layout with a footer include:
  # <html><body>{{ content_for_layout }} {% include 'shared/footer' %}</body></html>
  #
  # This will parse the template with a DatabaseFileSystem implementation rooted at 'template_path'.
  class DatabaseFileSystem
    def initialize(dynamic_template_klass, assigns = {}, options = {})
      @_dynamic_template_klass = dynamic_template_klass
      @_assigns = assigns; @_options = options
    end
    
    # Called by Liquid to retrieve a template file
    def read_template_file(template_path)
      _include = @_dynamic_template_klass.find_by_path(template_path)
      if _include
        _template = Liquid::Template.parse(_include.body)
        _template.render(@_assigns, @_options)
      end
    end
  end
end
