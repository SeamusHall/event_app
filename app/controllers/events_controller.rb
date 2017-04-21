class EventsController < ApplicationController
  load_and_authorize_resource
  before_action :load_nested_attributes, only: [:new, :edit]

  def show
    @order = Order.new
  end

  def create
    @event.save
    respond_with @event, location: -> { admin_path(action: 'events') }
  end

  def update
    @event.update(event_params)
    respond_with @event, location: -> { admin_path(action: 'events') }
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to admin_path(action: 'events'), notice: 'Event was successfully destroyed.' }
    end
  end

  private
  def event_params
    params.require(:event).permit(:name, :description, :page_body, :available_at, :unavailable_at, :starts_on, :ends_on,
      event_items_attributes: [:id, :event_id, :description, :price, :tax, :min_freq, :max_event, :max_order, :flat_rate])
  end

  def load_nested_attributes
    @event.event_items.to_a.size.upto 1 do
      @event.event_items.build
    end
  end
end
