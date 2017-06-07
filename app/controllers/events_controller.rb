class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  def index
    @events = Event.available
  end

  def show
    @order = Order.new
  end

  private

  def set_event
    if Event.find(params[:id]).available?
      @event = Event.find(params[:id])
    else
      flash[:error] = "You are not allowed to acess that page."
      redirect_to root_path
    end
  end

end
