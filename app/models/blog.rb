# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where('title LIKE ? OR content LIKE ?', "%#{term}%", "%#{term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  scope :fetch_user_blog, lambda { |user, blog_id|
    where('user_id = ? AND id = ?', user.id, blog_id)
  }

  scope :fetch_not_secret_blog, lambda { |blog_id|
    where('secret = false AND id = ?', blog_id)
  }

  def owned_by?(target_user)
    user == target_user
  end

  def fetch(user, blog_id)
    blog = if user
             Blog.fetch_user_blog(user, blog_id).or(Blog.fetch_not_secret_blog(blog_id))
           else
             Blog.fetch_not_secret_blog(blog_id)
           end
    blog.first!
  end
end
