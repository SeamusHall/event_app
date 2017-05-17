class EventsController < ApplicationController

  def index
    @events = Event.available
  end

  def show
    @order = Order.new
    @event = Event.find(params[:id])
  end

  private
  def event_params
    params.require(:event).permit(:name, :description, :page_body, :available_at, :unavailable_at, :starts_on, :ends_on,
      event_items_attributes: [:id, :event_id, :description, :price, :tax, :max_event, :max_order, :flat_rate])
  end

  def load_nested_attributes
    @event.event_items.to_a.size.upto 1 do
      @event.event_items.build
    end
  end
end
