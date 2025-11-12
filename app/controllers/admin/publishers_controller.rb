module Admin
  class PublishersController < ApplicationController
    before_action :set_publisher, only: [:edit, :update, :destroy]

    def index
      index_filtered
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'publishers', objects: @publishers.except(:limit, :offset),
                          title: 'Editoriales' }
          nom_fich = 'editoriales_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @publisher = Publisher.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @publisher = Publisher.new(publisher_params)
      if @publisher.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_publishers_tag',
              stream_action: :after,
              stream_locals: { publisher: @publisher },
              highlight_dom_id: "publisher_#{@publisher.id}",
              show_section_id: 'new_publishers_section'
            )
          end
          format.html { redirect_to admin_publishers_path, notice: 'Editorial creada correctamente' }
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
      if @publisher.update(publisher_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "publisher_#{@publisher.id}",
              stream_locals: { publisher: @publisher },
            )
          end
          format.html { redirect_to admin_publishers_path, notice: 'Editorial actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { publisher: @publisher })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @publisher.destroy
        msg = 'Editorial eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la editorial: ' + @publisher.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("publisher_#{@publisher&.id}")
          ]
        end
        format.html { redirect_to admin_publishers_path, notice: msg }
      end
    rescue => e
      redirect_to admin_publishers_path, alert: "Error al eliminar la editorial: #{e.message}"
    end

    private

    def index_filtered
      @filter_fields = [ ['Nombre','name','string'] ]
      @publishers = Publisher.order(:name)

      session[filter_scope] ||= {}
      value = session[filter_scope]['value'] if session[filter_scope]
      if value.present?
        case session[filter_scope]['type']
        when 'name'
          @publishers = @publishers.where("name LIKE ?", "%#{value}%")
        end
      end
      @publishers = @publishers.page(params[:page]).per(session[:per_page])
    end
    
    def set_publisher
      @publisher = Publisher.find(params[:id])
    end

    def publisher_params
      params.require(:publisher).permit(:name, :active)
    end
  end
end