require File.dirname(__FILE__) + '/spec_helper'

describe DynamicLiquidTemplates do
  describe "simple page resource with default layout" do
    it "should return the composed index action template" do
      @controller = FakeController.new("pages", "index")
      @controller.set(:pages, pages_collection)
      output = @controller.render_with_dynamic_liquid

      output.should include('<div id="header">Page Header</div>')
      output.should include('<link href="/stylesheets/scaffold.css" media="screen" rel="stylesheet" type="text/css" />')
      output.should include('<td>Foo</td>')
      output.should include('<td>Lorem Ipsum 1</td>')
      output.should include('<td><a href="/page/1">Show</a></td>')
      output.should include('<td><a href="/page/1/edit">Edit</a></td>')
      output.should include('<td>Bar</td>')
      output.should include('<td>Lorem Ipsum 2</td>')
      output.should include('<td><a href="/page/2">Show</a></td>')
      output.should include('<td><a href="/page/2/edit">Edit</a></td>')
      output.should include('<a href="/page/new">New Page</a><')
      output.should include('<div id="footer">Page Footer</div>')
    end
  end

  describe "simple post resource" do
    it "should return the composed index action template" do
      @controller = FakeController.new("posts", "index")
      @controller.set(:posts, posts_collection)
      output = @controller.render_with_dynamic_liquid
      
      output.should include('<link href="/stylesheets/scaffold.css" media="screen" rel="stylesheet" type="text/css" />')
      output.should include('<td>Foo</td>')
      output.should include('<td>Lorem Ipsum 1</td>')
      output.should include('<td><a href="/post/1">Show</a></td>')
      output.should include('<td><a href="/post/1/edit">Edit</a></td>')
      output.should include('<td>Bar</td>')
      output.should include('<td>Lorem Ipsum 2</td>')
      output.should include('<td><a href="/post/2">Show</a></td>')
      output.should include('<td><a href="/post/2/edit">Edit</a></td>')
      output.should include('<a href="/post/new">New Post</a><')
    end
  
    it "should return the composed show action template" do
      @controller = FakeController.new("posts", "show")
      @controller.set(:post, post_object)
      output = @controller.render_with_dynamic_liquid
      
      # output.should include('teste')
      output.should include('<h2>Foo</h2>')
      output.should include('Lorem Ipsum 1')
      output.should include('<a href="/post/1/edit">Edit</a> |')
      output.should include('<a href="/posts">Back</a>')
    end
    
    it "should return the composed edit action template" do
      @controller = FakeController.new("posts", "edit")
      @controller.set(:post, post_object)
      output = @controller.render_with_dynamic_liquid
      
      output.should include('<h1>Editing post</h1>')
      output.should include('<form action="/post/1" class="edit_post" id="edit_post_1" method="post">')
      output.should include('<input id="post_title" name="post[title]" size="30" type="text" value="Foo" />')
      output.should include('<textarea cols="40" id="post_body" name="post[body]" rows="20">Lorem Ipsum 1</textarea>')
      output.should include('<a href="/post/1">Show</a> |')
      output.should include('<a href="/posts">Back</a>')
    end
    
    it "should return the composed new action template" do
      @controller = FakeController.new("posts", "new")
      @controller.set(:post, post_object)
      output = @controller.render_with_dynamic_liquid

      output.should include('<h1>New post</h1>')
      output.should include('<form action="/posts" class="new_post" id="new_post" method="post">')
      output.should include('<a href="/posts">Back</a>')
    end
  end

  describe "nested post/comment resource" do
    before(:each) do
      @controller = FakeController.new("comments", "index")
      @controller.class_eval do
        def parent
          post_object
        end
      end
    end
    it "should return composed index action template" do
      @controller.set(:comments, comments_collection)
      output = @controller.render_with_dynamic_liquid
      
      output.should include('<link href="/stylesheets/scaffold.css" media="screen" rel="stylesheet" type="text/css" />')
      output.should include('<h1>Listing comments</h1>')
      output.should include('<td>Lorem Ipsum 1</td>')
      output.should include('<td><a href="/post/1/comment/1">Show</a></td>')
      output.should include('<td><a href="/post/1/comment/1/edit">Edit</a></td>')
      output.should include('<td>Lorem Ipsum 2</td>')
      output.should include('<td><a href="/post/1/comment/2">Show</a></td>')
      output.should include('<td><a href="/post/1/comment/2/edit">Edit</a></td>')
      output.should include('<a href="/post/1/comments/new">New Comment</a>')
    end
    it "should return composed show action template" do
      @controller.action_name = "show"
      @controller.set(:comment, comment_object)
      output = @controller.render_with_dynamic_liquid
      
      output.should include('Lorem Ipsum 1')
      output.should include('<a href="/post/1/comment/1/edit">Edit</a> |')
      output.should include('<a href="/post/1/comments">Back</a>')
    end
    it "should return composed edit action template" do
      @controller.action_name = "edit"
      @controller.set(:comment, comment_object)
      output = @controller.render_with_dynamic_liquid
      
      output.should include('<h1>Editing comment</h1>')
      output.should include('<form action="/post/1/comment/1" class="edit_comment" id="edit_comment_1" method="comment">')
      output.should include('<textarea cols="40" id="comment_comment" name="comment[comment]" rows="20">Lorem Ipsum 1</textarea>')
      output.should include('<a href="/post/1/comment/1">Show</a> |')
      output.should include('<a href="/post/1/comments">Back</a>')
    end
    it "should return composed new action template" do
      @controller.action_name = "new"
      @controller.set(:comment, comment_object)
      output = @controller.render_with_dynamic_liquid
      
      output.should include('<h1>New comment</h1>')
      output.should include('<form action="/post/1/comments" class="new_comment" id="new_comment" method="comment">')
      output.should include('<a href="/post/1/comments">Back</a>')
    end
  end

  describe "namespaced post resource" do
    it "should return composed index action template" do
      @controller = FakeController.new("posts", "index")
      @controller.set(:posts, posts_collection)
      output = @controller.render_with_dynamic_liquid(:namespace => "admin")
      
      output.should include('<link href="/stylesheets/scaffold.css" media="screen" rel="stylesheet" type="text/css" />')
      output.should include('<td>Foo</td>')
      output.should include('<td>Lorem Ipsum 1</td>')
      output.should include('<td><a href="/admin/post/1">Show</a></td>')
      output.should include('<td><a href="/admin/post/1/edit">Edit</a></td>')
      output.should include('<td>Bar</td>')
      output.should include('<td>Lorem Ipsum 2</td>')
      output.should include('<td><a href="/admin/post/2">Show</a></td>')
      output.should include('<td><a href="/admin/post/2/edit">Edit</a></td>')
      output.should include('<a href="/admin/post/new">New Post</a><')
    end
    it "should return composed show action template" do
      @controller = FakeController.new("posts", "show")
      @controller.set(:post, post_object)
      output = @controller.render_with_dynamic_liquid(:namespace => "admin")
      
      output.should include('<h2>Foo</h2>')
      output.should include('Lorem Ipsum 1')
      output.should include('<a href="/admin/post/1/edit">Edit</a> |')
      output.should include('<a href="/admin/posts">Back</a>')
    end
    it "should return composed edit action template" do
      @controller = FakeController.new("posts", "edit")
      @controller.set(:post, post_object)
      output = @controller.render_with_dynamic_liquid(:namespace => "admin")
      
      output.should include('<h1>Editing post</h1>')
      output.should include('<form action="/admin/post/1" class="edit_post" id="edit_post_1" method="post">')
      output.should include('<input id="post_title" name="post[title]" size="30" type="text" value="Foo" />')
      output.should include('<textarea cols="40" id="post_body" name="post[body]" rows="20">Lorem Ipsum 1</textarea>')
      output.should include('<a href="/admin/post/1">Show</a> |')
      output.should include('<a href="/admin/posts">Back</a>')
    end
    it "should return composed new action template" do
      @controller = FakeController.new("posts", "new")
      @controller.set(:post, post_object)
      output = @controller.render_with_dynamic_liquid(:namespace => "admin")

      output.should include('<h1>New post</h1>')
      output.should include('<form action="/admin/posts" class="new_post" id="new_post" method="post">')
      output.should include('<a href="/admin/posts">Back</a>')
    end
  end
end