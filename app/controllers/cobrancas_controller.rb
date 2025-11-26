class CobrancasController < ApplicationController
  before_action :set_cobranca, only: [:registrar_pagamento]

  def new_pagamento
    @cobranca = Cobranca.find(params[:id])
    @pagamento = @cobranca.pagamentos.build
  end

  def registrar_pagamento
    service = CobrancaServices::RegistrarPagamentoService.new(@cobranca, pagamento_params)
    @pagamento = service.call

    if service.success?
      respond_to do |format|
        format.html { redirect_to responsavel_cobrancas_path(@cobranca.plano_pagamento.responsavel_financeiro), notice: 'Pagamento registrado com sucesso!' }
        format.json { render json: @pagamento.as_json(
          include: {
            cobranca: { only: [:id, :valor, :data_vencimento, :metodo_pagamento, :status, :codigo_pagamento] }
          }
        ), status: :created }
      end
    else
      @pagamento = @cobranca.pagamentos.build(pagamento_params)
      respond_to do |format|
        format.html { render :new_pagamento, status: :unprocessable_entity }
        format.json { render json: { errors: service.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_cobranca
    @cobranca = Cobranca.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Cobrança não encontrada' }, status: :not_found
  end

  def pagamento_params
    params.require(:pagamento).permit(:valor, :data_pagamento)
  end
end

