# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: :show
  before_action :set_correct_user_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
    @blog = Blog.find(0) if current_user && @blog.secret == true && @blog.user_id != current_user.id
    @blog = Blog.find(0) unless current_user
  end

  def blog_params
    permitted_params = params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
    permitted_params[:random_eyecatch] = false unless current_user.premium?
    permitted_params
  end

  def set_correct_user_blog
    @blog = current_user.blogs.find(params[:id])
  end
end
