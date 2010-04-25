module DynamicLiquidTemplates
  # Renders using Liquid as the template engine and reloads the templates from the
  # database instead of files.
  #
  # * <tt>:collection</tt> - the name of the collection array (convention: controller name)
  # * <tt>:object</tt> - the name of the single model object (convention: model name)
  # * <tt>:layout</tt> - name of the layout template (convention: controller_name)
  # * <tt>:controller</tt> - if you're not following the naming conventions you can 
  #   override the controller name
  # * <tt>:action</tt> - if you're not following the naming conventions you can override 
  #   the action name
  # * <tt>:dynamic_template_class</tt> - name of the model that searches the correct Liquid 
  #   template (default: DynamicTemplate)
  #
  # == Dynamic Template
  #
  # This will only work if there is a proper model that handles retrieving Liquid templates from the
  # database. The minimal schema is to have a string 'path' column and a text 'body' column. Paths
  # will be such as 'posts/show', 'posts/index' or 'layouts/posts'.
  # 
  # == Overrides
  #
  # This method expects to find a 'parent' method defined in the controller that returns the
  # parent model object in case this is a nested controller
  #
  # == Returns
  #
  # It will correctly assign needed instance variables to Liquid. It will also modify the
  # model class to add +show_path+  and +edit_path+ caches to be called within the Liquid
  # template. It also supports one level nested resource named routes.
  #
  # This way, the only need you have to do in your controller, if it follows normal 
  # conventions is to add this method to the 'format.html' call within the 'respond_to'
  # block, and it will do everything necessary
  #
  # You will also receive the usually expected 'posts' and 'post' named variables, 
  # following your controller name. It will also create 'collection' and 'object' so you
  # can make your templates more generic. And if you have defined the 'parent' method in
  # your controller you will also get a 'parent' drop in your template.
  #
  # == Requirements
  #
  # Don't forget to add the Liquid gem to your environment.rb file:
  #
  #   config.gem "tobi-liquid", :lib => "liquid", :source => "http://gems.github.com"
  #
  def render_with_dynamic_liquid(assigns = {})
    _controller_name          = assigns.delete(:controller)      || self.controller_name
    _model_name               = _controller_name.singularize
    _collection_variable_name = (assigns.delete(:collection)     || "@#{_controller_name}").to_s # @comments
    _object_variable_name     = (assigns.delete(:object)         || "@#{_model_name}").to_s      # @comment
    _parent_name              = respond_to?(:parent) ? "#{parent.class.name.underscore}_" : nil
    _namespace                = assigns.include?(:namespace) ? "#{assigns[:namespace]}_" : nil
    _scope                    = assigns[:scope]
    
    instance_variables.each do |variable|
      # discovers variables and path for index action
      case variable
      when _collection_variable_name:
        assigns.merge!( "collection"     => instance_variable_get(variable) ) 
        assigns.merge!( _controller_name => instance_variable_get(variable) ) 
      # discovers variables for all the other actions
      when _object_variable_name:
        # post_comment_path(@post, @comment) or comment_path(@comment)
        _object_named_route = "#{_namespace}#{_parent_name}#{_model_name}_path(#{_parent_name ? 'parent, ' : nil}instance_variable_get(variable))" 

        assigns.merge!( "object_path" => eval(_object_named_route) ) rescue nil
        assigns.merge!( "object"      => instance_variable_get(variable) )
        assigns.merge!( _model_name   => instance_variable_get(variable) ) 
      end
    end
    
    # if this is a nested resource, override the 'parent' method to return the parent object
    if _parent_name
      # posts_path(@post)
      assigns.merge!( "parent"      => parent )
      assigns.merge!( "parent_path" => eval("#{_namespace}#{_parent_name}path(#{_parent_name ? 'parent' : nil})") ) rescue nil 
    end
    
    # post_comments_path(@posts), new_post_comment_path(@posts)
    # comments_path, new_comment_path
    _collection_named_route = "#{_namespace}#{_parent_name}#{_controller_name}_path(#{_parent_name ? 'parent' : nil})"
    _new_named_route        = "new_#{_namespace}#{_parent_name}#{_model_name}_path(#{_parent_name ? 'parent' : nil})"

    assigns.merge!( "collection_path" => eval(_collection_named_route) ) rescue nil
    assigns.merge!( "new_object_path" => eval(_new_named_route) ) rescue nil

    if assigns["object"] && assigns["object"].id && !assigns["collection"]
      assigns.merge!("collection" => [assigns["object"]])
    end

    _object      = assigns["collection"].try(:first)
    _object_name = if _object
      # create attributes to cache resource paths
      unless _object.respond_to?(:_show_path)
        _object.class.class_eval do
          attr_accessor :_show_path
          attr_accessor :_edit_path
        end
      end
      # override liquid serializer to add the cached resource paths
      if _object.respond_to?(:to_liquid) && !_object.respond_to?(:to_liquid_old)
        _object.class.class_eval do
          alias :to_liquid_old :to_liquid
          def to_liquid
            to_liquid_old.merge(
              'show_path' => self._show_path, 
              'edit_path' => self._edit_path )
          end
        end
      end
      _object.class.name.underscore
    end

    # cache each model named_route into itself
    if assigns["collection"]
      assigns["collection"].each do |_object|
        # post_comment_path(parent, @comment), edit_post_comment_path(parent, @comment)
        # comment_path(@comment), edit_comment_path(@comment)
        _show_path = "#{_namespace}#{_parent_name}#{_object_name}_path(#{_parent_name ? 'parent, ' : nil}_object)"
        _edit_path = "edit_#{_namespace}#{_parent_name}#{_object_name}_path(#{_parent_name ? 'parent, ' : nil}_object)"

        _object._show_path = lambda{ eval(_show_path) }
        _object._edit_path = lambda{ eval(_edit_path) }
      end
    end

    assigns.merge!("form_authenticity_token" => form_authenticity_token)

    # begin Liquid rendering procedure
    _dynamic_template_klass = assigns.delete(:dynamic_template_class) || DynamicTemplate
    
    _namespace_dir = assigns.include?(:namespace) ? "#{assigns.delete(:namespace)}/" : nil
    _layout_path   = assigns[:layout] == false ? nil : ( assigns.delete(:layout) || "layouts/#{_namespace_dir}#{_controller_name}" )
    _default_layout_path = "layouts/application"
    _template_path = "#{_namespace_dir}#{_controller_name}/#{assigns.delete(:action) || self.action_name}"
    
    options = { :filters => [master_helper_module], :registers => {
      :action_view => ActionView::Base.new([], {}, self), 
      :controller  => self
    } }
    
    _filesystem = Liquid::Template.file_system = DynamicLiquidTemplates::DatabaseFileSystem.new(_dynamic_template_klass, assigns, options)
    if _layout_path
      _dynamic_layout = _dynamic_template_klass.from_scope(_scope).find_by_path(_layout_path) || _dynamic_template_klass.from_scope(_scope).find_by_path(_default_layout_path)
      _layout   = Liquid::Template.parse(_dynamic_layout.body) 
    end
    _template = Liquid::Template.parse(_dynamic_template_klass.from_scope(_scope).find_by_path(_template_path).body)

    _rend_temp      = _template.render(assigns, options)
    _rend_layout    = _layout.render({'content_for_layout' => _rend_temp}, options) if _layout_path

    headers["Content-Type"] ||= 'text/html; charset=utf-8'
    render :text => _layout_path ? _rend_layout : _rend_temp
  end
end
