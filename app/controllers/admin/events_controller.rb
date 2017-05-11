module Admin
  class EventsController < AdminController
    before_action :set_event, only: [:edit,:show,:update]

    def index
      @events = Event.all.page params[:page]
    end

    def new
      @event = Event.new
      load_nested_attributes
    end

    def edit
      load_nested_attributes
    end

    def create
      @event = Event.new(event_params)
      if @event.save
        redirect_to admin_events_path, notice: 'Event was successfully created.'
      else
        render "new"
      end
    end

    def update
      if @event.update(event_params)
        redirect_to admin_events_path, notice: 'Event was successfully updated.'
      else
        render "edit"
      end
    end

    def destroy
      @event.destroy
      respond_to do |format|
        format.html { redirect_to admin_events_path, notice: 'Event was successfully destroyed.' }
      end
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:name, :description, :page_body, :available_at, :unavailable_at, :starts_on, :ends_on,
        event_items_attributes: [:id, :event_id, :description, :price, :tax, :min_freq, :max_event, :max_order, :flat_rate])
    end

    def load_nested_attributes
      @event.event_items.to_a.size.upto 0 do
        @event.event_items.build
      end
    end
  end
end
