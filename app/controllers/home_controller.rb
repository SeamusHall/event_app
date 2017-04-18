class HomeController < ApplicationController
  def index
    @events = Event.available
  end
end
