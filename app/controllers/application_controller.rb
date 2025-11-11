class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Authentication
  before_action :authenticate_user!
  # Define global pagination
  before_action :set_pagination
  # Initialize filter
  before_action :initialize_filter
  # Locales
  #around_action :set_locale

  private

  def set_locale(&action)
    #I18n.locale = params[:locale] || I18n.default_locale
    #I18n.with_locale(locale, &action)
  end

  def set_pagination
    session[:per_page] = params[:per_page] ||= 20
  end

  def initialize_filter
    session[filter_scope] ||= {}
  end

  def filter_scope
    "#{params[:controller]}_filter"
  end
end
