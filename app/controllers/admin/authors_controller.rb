module Admin
  class AuthorsController < ApplicationController
    before_action :set_author, only: [:edit, :update, :destroy]

    def index
      @authors = Author.order(:name).page(params[:page]).per(session[:per_page])
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
            scroll_and_close = view_context.javascript_tag(
              "(function(){\n"+
              "  var el=document.getElementById('author_#{@author.id}');\n"+
              "  if(el){\n"+
              "    el.classList.add('flash-highlight');\n"+
              "    el.scrollIntoView({behavior:'smooth',block:'center'});\n"+
              "    setTimeout(function(){ el.classList.remove('flash-highlight'); }, 1600);\n"+
              "  }\n"+
              "  var m=document.getElementById('modal');\n"+
              "  if(m){ setTimeout(function(){ m.innerHTML='' }, 300); }\n"+
              "})();"
            )
            render turbo_stream: [
              turbo_stream.after('author_new', partial: 'author', locals: { author: @author }),
              turbo_stream.update('modal', scroll_and_close)
            ]
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
            render turbo_stream: [
              turbo_stream.replace("author_#{@author.id}", partial: 'author', locals: { author: @author }),
            ]
          end
          format.html { redirect_to admin_authors_path, notice: 'Autor actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("author_#{@author.id}_sub", partial: 'form', locals: { author: @author })
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

    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :active)
    end
  end
end