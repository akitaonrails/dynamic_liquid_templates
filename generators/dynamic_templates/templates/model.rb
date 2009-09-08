class DynamicTemplate < ActiveRecord::Base
  validates_presence_of :path
  validates_presence_of :body
end
