# app/controllers/stream_posts_controller.rb
class StreamPostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_stream_post
    
    def approve
      @stream_post.update(approved: true)
      redirect_to dashboard_path, notice: "Post approved for stream"
    end
    
    def hide
      @stream_post.update(approved: false)
      redirect_to dashboard_path, notice: "Post hidden from stream"
    end
    
    private
    
    def set_stream_post
      @stream_post = current_account.stream_posts.find(params[:id])
    end
  end