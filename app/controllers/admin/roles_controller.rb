module Admin
  class RolesController < AdminController
    load_and_authorize_resource
    before_action :set_role, only: [:edit,:show,:update]

    def index
      @roles = Role.all
    end

    def create
      if @role.save
        redirect_to admin_role_path(@role), notice: 'Role was successfully created.'
      else
        render "new"
      end
    end

    def update
      if @role.update(role_params)
        redirect_to admin_role_path(@role), notice: 'Role was successfully updated.'
      else
        render "edit"
      end
    end

    private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:name, :description)
    end
  end
end
