class EventsController < ApplicationController

  def index
    @events = Event.available
  end

  def show
    @order = Order.new
    @event = Event.find(params[:id])
  end

end
