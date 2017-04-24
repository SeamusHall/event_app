class RolesController < ApplicationController
  load_and_authorize_resource
  layout "admin"
  
  def create
    @role.save
    respond_with @role, location: -> { roles_path }
  end

  def update
    @role.update(role_params)
    respond_with @role, location: -> { roles_path }
  end

  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to roles_url, notice: 'Role was successfully destroyed.' }
    end
  end

  private
  def role_params
    params.require(:role).permit(:name, :description)
  end
end
