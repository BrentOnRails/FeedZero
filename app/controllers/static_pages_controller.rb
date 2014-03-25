class StaticPagesController < ApplicationController


  def index
    if current_user
      @feed = current_user.facebook.get_connection("me","feed")
      render :index
    else
      render :show
    end
  end
end
