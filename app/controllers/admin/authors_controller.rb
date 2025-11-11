module Admin
  class AuthorsController < ApplicationController
    before_action :set_author, only: [:edit, :update, :destroy]

    def index
    end

    def new
      @author = Author.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @author = Author.new(author_params)
      if @author.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_authors_tag',
              stream_action: :after,
              stream_locals: { author: @author },
              highlight_dom_id: "author_#{@author.id}",
              show_section_id: 'new_authors_section'
            )
          end
          format.html { redirect_to admin_authors_path, notice: 'Autor creado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity))
            ]
          end
          format.html { render :new, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def update
      if @author.update(author_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "author_#{@author.id}",
              stream_locals: { author: @author },
            )
          end
          format.html { redirect_to admin_authors_path, notice: 'Autor actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { author: @author })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @author.destroy
        msg = 'Autor eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el autor: ' + @author.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("author_#{@author&.id}")
          ]
        end
        format.html { redirect_to admin_authors_path, notice: msg }
      end
    rescue => e
      redirect_to admin_authors_path, alert: "Error al eliminar el autor: #{e.message}"
    end

    private

    def index_filtered
      @filter_fields = [ ['Nombre','name','string'] ]
      @authors = Author.order(:name)
      value = session[filter_scope]['value']
      if session[filter_scope] && value.present?
        case session[filter_scope]['type']
        when 'name'
          @authors = @authors.where("name LIKE ?", "%#{value}%")
        end
      end
      @authors = @authors.page(params[:page]).per(session[:per_page])
    end
    
    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :active)
    end
  end
end