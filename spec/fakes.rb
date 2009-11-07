class DynamicTemplate
  attr_accessor :path, :body

  # fake to return static fixtures instead of hitting the database
  def self.find_by_path(path)
    model = DynamicTemplate.new
    # replace the admin subdir just so we don't need to duplicate the posts template
    path.gsub!('admin/', '') if path =~ /admin/
    model.path = "#{File.dirname(__FILE__)}/fixtures/#{path}.liquid"
    if File.exist? model.path
      model.body = File.read(model.path)
      model
    else
      nil
    end
  end
end

class FakeController
  include DynamicLiquidTemplates
  attr_accessor :controller_name, :action_name, :form_authenticity_token
  
  def initialize(controller_name, action_name)
    self.controller_name = controller_name
    self.action_name     = action_name
    self.form_authenticity_token = "jCgpavsSMAmehyylFLcs/mOSsw4V+5T7hadcVaMckrg="
    
    master_helper_module.module_eval do
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::UrlHelper
    end
  end
  
  def master_helper_module
    @module ||= Module.new
  end
  
  def headers
    @headers ||= {}
  end
  
  def render(options = {})
    options[:text]
  end
  
  def set(name, value)
    instance_variable_set("@#{name}", value)
  end
  
  # simulating named routes
  
  def pages_path
    "/pages"
  end
  
  def page_path(obj)
    "/page/#{obj.to_param}"
  end
  
  def new_page_path
    "/page/new"
  end
  
  def edit_page_path(obj)
    "/page/#{obj.to_param}/edit"
  end
  
  def posts_path
    "/posts"
  end
  
  def post_path(obj)
    "/post/#{obj.to_param}"
  end
  
  def new_post_path
    "/post/new"
  end
  
  def edit_post_path(obj)
    "/post/#{obj.to_param}/edit"
  end
  
  def post_comments_path(obj)
    "/post/#{obj.to_param}/comments"
  end
  
  def post_comment_path(obj1, obj2)
    "/post/#{obj1.to_param}/comment/#{obj2.to_param}"
  end
  
  def new_post_comment_path(obj)
    "/post/#{obj.to_param}/comments/new"
  end
  
  def edit_post_comment_path(obj1, obj2)
    "/post/#{obj1.to_param}/comment/#{obj2.to_param}/edit"
  end
  
  def admin_posts_path
    "/admin/posts"
  end
  
  def admin_post_path(obj)
    "/admin/post/#{obj.to_param}"
  end
  
  def new_admin_post_path
    "/admin/post/new"
  end
  
  def edit_admin_post_path(obj)
    "/admin/post/#{obj.to_param}/edit"
  end
end

class Post
  attr_accessor :id, :title, :body, :comments
  
  def initialize(options = {})
    self.id = options[:id]
    self.title = options[:title]
    self.body = options[:body]
    self.comments = options[:comments] || []
    self.comments.each { |comment| comment.post = self }
  end
  
  def to_liquid
    {
      'id'    => self.id,
      'title' => self.title,
      'body'  => self.body
    }
  end
  
  def to_param
    self.id
  end
end

class Page
  attr_accessor :id, :title, :body
  
  def initialize(options = {})
    self.id = options[:id]
    self.title = options[:title]
    self.body = options[:body]
  end
  
  def to_liquid
    {
      'id'    => self.id,
      'title' => self.title,
      'body'  => self.body
    }
  end
  
  def to_param
    self.id
  end
end

class Comment
  attr_accessor :id, :comment, :post
  
  def initialize(options = {})
    self.id = options[:id]
    self.comment = options[:comment]
    self.post = options[:post]
    self.post.comments << self if self.post
  end
  
  def to_liquid
    {
      'id' => self.id,
      'comment' => self.comment
    }
  end
  
  def to_param
    self.id
  end
end