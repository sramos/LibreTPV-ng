module Admin
  class EditorsController < ApplicationController
    before_action :set_editor, only: [:edit, :update, :destroy]

    def index
      @editors = Editor.order(:name).page(params[:page]).per(session[:per_page])
    end

    def new
      @editor = Editor.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @editor = Editor.new(editor_params)
      if @editor.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_editors_tag',
              stream_action: :after,
              stream_locals: { editor: @editor },
              highlight_dom_id: "editor_#{@editor.id}",
              show_section_id: 'new_editors_section'
            )
          end
          format.html { redirect_to admin_editors_path, notice: 'Editorial creada correctamente' }
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
      if @editor.update(editor_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "editor_#{@editor.id}",
              stream_locals: { editor: @editor },
            )
          end
          format.html { redirect_to admin_editors_path, notice: 'Editorial actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { editor: @editor })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @editor.destroy
        msg = 'Editorial eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la editorial: ' + @editor.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("editor_#{@editor&.id}")
          ]
        end
        format.html { redirect_to admin_editors_path, notice: msg }
      end
    rescue => e
      redirect_to admin_editors_path, alert: "Error al eliminar la editorial: #{e.message}"
    end

    private

    def set_editor
      @editor = Editor.find(params[:id])
    end

    def editor_params
      params.require(:editor).permit(:name, :active)
    end
  end
end