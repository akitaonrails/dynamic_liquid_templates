require 'rubygems'
require 'activesupport'
require 'action_controller'
require 'action_view'
gem 'tobi-liquid'
require 'liquid'
require 'spec'
require 'ruby-debug'
require File.dirname(__FILE__) + '/../lib/dynamic_liquid_templates.rb'
require File.dirname(__FILE__) + '/../lib/database_file_system.rb'
require File.dirname(__FILE__) + '/fakes.rb'

Spec::Runner.configure do |config|

end

def posts_collection
  [
    Post.new(:id => 1, :title => "Foo", :body => "Lorem Ipsum 1"),
    Post.new(:id => 2, :title => "Bar", :body => "Lorem Ipsum 2")
  ]
end

def pages_collection
  [
    Page.new(:id => 1, :title => "Foo", :body => "Lorem Ipsum 1"),
    Page.new(:id => 2, :title => "Bar", :body => "Lorem Ipsum 2")
  ]
end

def post_object
  Post.new(:id => 1, :title => "Foo", :body => "Lorem Ipsum 1")
end

def comments_collection
  @post = post_object
  @comments = [
    Comment.new(:id => 1, :comment => "Lorem Ipsum 1", :post => @post),
    Comment.new(:id => 2, :comment => "Lorem Ipsum 2", :post => @post),
  ]
  @post.comments = @comments
end

def comment_object
  @post = post_object
  Comment.new(:id => 1, :comment => "Lorem Ipsum 1", :post => @post)
end