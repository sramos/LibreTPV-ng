class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Authentication
  before_action :authenticate_user!
  # Locales
  around_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
end
