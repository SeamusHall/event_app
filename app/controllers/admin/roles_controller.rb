module Admin
  class RolesController < AdminController
    before_action :set_role, only: [:edit,:show,:update]

    def index
      @roles = Role.all
    end

    def create
      @role.save
      respond_with(@role)
    end

    def update
      @role.update(role_params)
      respond_with(@role)
    end

    def destroy
      @role.destroy
      respond_to do |format|
        format.html { redirect_to admin_roles_path, notice: 'Role was successfully destroyed.' }
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
