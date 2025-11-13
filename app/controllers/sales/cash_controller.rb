module Sales
  class CashController < ApplicationController

    def index
      @cashs = Cash.order(date: :desc).page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'cash', objects: @cashs.except(:limit, :offset),
                          title: 'Movimientos de caja', filter_scope: filter_scope }
          nom_fich = 'movimientos_de_caja_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @cash = Cash.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @cash = Cash.new(date: DateTime.now, cash_count: false)
      if @cash.update(cash_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_cash_tag',
              stream_action: :after,
              stream_locals: { cash: @cash },
              highlight_dom_id: "cash_#{@cash.id}"
            )
          end
          format.html { redirect_to sales_cash_path, notice: 'Movimiento de caja creado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity, locals: { cash: @cash }))
            ]
          end
          format.html { render :new, status: :unprocessable_entity, layout: false }
        end
      end
    end

    private

    def cash_params
      params.require(:cash).permit(:amount, :comments)
    end
  end
end