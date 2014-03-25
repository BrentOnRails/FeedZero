class StaticPagesController < ApplicationController


  def index
    @feed = current_user.facebook.get_connection("me","feed")
    render :index
  end
end
