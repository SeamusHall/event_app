module Admin
  class CategoriesController < AdminController
    before_action :set_category, only: [:edit, :update]

    respond_to :html

    def index
      @categories = Category.all
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        respond_with @category, location: -> { ["admin", @category] }
      else
        render "new"
      end
    end

    def update
      if @category.update(category_params)
        respond_with @category, location: -> { ["admin", @category] }
      else
        render "edit"
      end
    end

    private
      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :description)
      end
  end
end
