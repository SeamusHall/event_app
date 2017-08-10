class RestoreController < ApplicationController

  def new
  end

  def create
    # Check find the record based off of email, and if deleted_at is not null
    user = User.only_deleted.where(email: params[:email])
    # The use of ids here is fine because it should only return one record
    # users can't have the same emails
    User.restore(user.ids)
    redirect_to root_path, notice: "Account Succefully restored"
  end
end
