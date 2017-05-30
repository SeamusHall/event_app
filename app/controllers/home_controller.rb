class HomeController < ApplicationController
  before_action :cart_initializer

  def index
    @events = Event.available
    @products = Product.all.where(published: true)
  end
end
