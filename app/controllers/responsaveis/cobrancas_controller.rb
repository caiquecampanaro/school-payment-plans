module Responsaveis
  class CobrancasController < ApplicationController
    before_action :set_responsavel

    def index
      @cobrancas = Cobranca.joins(plano_pagamento: :responsavel_financeiro)
                           .where(responsaveis_financeiros: { id: @responsavel.id })
                           .includes(:plano_pagamento)
                           .order(:data_vencimento)

      respond_to do |format|
        format.html
        format.json {
          cobrancas_com_status = @cobrancas.map do |cobranca|
            cobranca_hash = cobranca.as_json(only: [:id, :valor, :data_vencimento, :metodo_pagamento, :status, :codigo_pagamento])
            cobranca_hash['vencida'] = cobranca.vencida?
            cobranca_hash['plano_id'] = cobranca.plano_pagamento_id
            cobranca_hash['plano'] = {
              id: cobranca.plano_pagamento.id,
              centro_de_custo: cobranca.plano_pagamento.centro_de_custo.nome
            }
            cobranca_hash
          end
          render json: cobrancas_com_status
        }
      end
    end

    def quantidade
      quantidade = Cobranca.joins(plano_pagamento: :responsavel_financeiro)
                          .where(responsaveis_financeiros: { id: @responsavel.id })
                          .count
      respond_to do |format|
        format.html { redirect_to responsavel_cobrancas_path(@responsavel) }
        format.json { render json: { quantidade: quantidade } }
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

