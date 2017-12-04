class DocsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_authorized
  layout 'docs'

  private
    def ensure_authorized
      raise CanCan::AccessDenied unless current_user.has_role?(:admin)
      @admin_page = true
    end
end
