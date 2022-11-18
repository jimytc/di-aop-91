require "test_helper"

class PostTest < ActiveSupport::TestCase
  test '.persisted?' do
    post = Post.create!(title: 'hello')
    assert post.persisted?
  end
end
