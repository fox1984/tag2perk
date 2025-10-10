# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def show  # <-- THIS ONE, NOT INDEX
    # If no current_account, redirect to accounts
    unless current_account
      redirect_to accounts_path, alert: "Please select an account first"
      return
    end
    
    @accounts = current_account
    @stream_posts = @accounts.stream_posts.order(timestamp: :desc).limit(20)
    @pending_count = @accounts.stream_posts.where(approved: false).count
  end
end