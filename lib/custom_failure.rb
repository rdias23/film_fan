class CustomFailure < Devise::FailureApp
  def redirect_url
    "/"
  end

  def respond
    if http_auth?
      http_auth
    else
        redirect
        flash[:notice] = I18n.t(:unauthenticated, :scope => [ :devise, :failure ])
    end
  end
end
