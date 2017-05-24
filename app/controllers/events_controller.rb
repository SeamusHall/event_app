class EventsController < ApplicationController

  def index
    @events = Event.available
  end

  def show
    @order = Order.new
    @event = Event.find(params[:id])
  end

  # automatically update users role to regular user
  # so that user can edit there information in order to
  # make payments
  def auto_update_role
    @user = current_user
    unless @user.roles.any?
      @user.role_ids = [2]
      @user.save
    end
    redirect_to edit_user_path(@user)
  end
end
