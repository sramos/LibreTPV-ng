class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Authentication
  before_action :authenticate_user!
  # Define global pagination
  before_action :set_pagination
  # Locales
  #around_action :set_locale

  # Common filter method for all controllers
  def filter
    if params[:filter] && session[filter_scope]
      session[filter_scope]['type'] = params[:filter][:type].blank? ? nil : params[:filter][:type]
      session[filter_scope]['value'] = params[:filter][:value].blank? ? nil : params[:filter][:value]
      session[filter_scope]['condition'] = params[:filter][:condition].blank? ? nil : params[:filter][:condition]
      puts "session[filter_scope]: #{session[filter_scope]}"
    end
    redirect_to action: :index
  end

  private

  def set_locale(&action)
    #I18n.locale = params[:locale] || I18n.default_locale
    #I18n.with_locale(locale, &action)
  end

  def set_pagination
    unless session[:per_page]
      default_value = Config.value('PAGINATE')&.to_i
      session[:per_page] = default_value && default_value > 0 ? default_value : 20
    end
    session[:per_page]   = params[:per_page] if params[:per_page]
  end
  
  def filter_scope
    "#{params[:controller]}_filter"
  end
end
