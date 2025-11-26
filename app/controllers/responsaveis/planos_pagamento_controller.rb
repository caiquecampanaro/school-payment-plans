module Responsaveis
  class PlanosPagamentoController < ApplicationController
    before_action :set_responsavel

    def index
      @planos_pagamento = @responsavel.planos_pagamento.includes(:centro_de_custo, :cobrancas)
      respond_to do |format|
        format.html
        format.json { render json: @planos_pagamento.as_json(
          include: {
            centro_de_custo: { only: [:id, :nome, :codigo, :tipo] },
            cobrancas: { only: [:id, :valor, :data_vencimento, :metodo_pagamento, :status, :codigo_pagamento] }
          },
          methods: [:valor_total]
        ) }
      end
    end

    private

    def set_responsavel
      @responsavel = ResponsavelFinanceiro.find(params[:responsavel_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Responsável financeiro não encontrado' }, status: :not_found
    end
  end
end

