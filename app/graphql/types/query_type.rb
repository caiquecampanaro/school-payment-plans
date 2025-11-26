module Types
  class QueryType < BaseObject
    field :plano_pagamento, PlanoPagamentoType, null: true do
      argument :id, ID, required: true
    end

    field :planos_pagamento, [PlanoPagamentoType], null: true do
      argument :responsavel_id, ID, required: false
    end

    field :centros_de_custo, [CentroDeCustoType], null: true

    field :cobrancas, [CobrancaType], null: true do
      argument :responsavel_id, ID, required: true
    end

    field :cobrancas_quantidade, Integer, null: false do
      argument :responsavel_id, ID, required: true
    end

    def plano_pagamento(id:)
      PlanoPagamento.find(id)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def planos_pagamento(responsavel_id: nil)
      if responsavel_id
        ResponsavelFinanceiro.find(responsavel_id).planos_pagamento
      else
        PlanoPagamento.all
      end
    end

    def centros_de_custo
      CentroDeCusto.ativos
    end

    def cobrancas(responsavel_id:)
      Cobranca.joins(plano_pagamento: :responsavel_financeiro)
              .where(responsaveis_financeiros: { id: responsavel_id })
    end

    def cobrancas_quantidade(responsavel_id:)
      Cobranca.joins(plano_pagamento: :responsavel_financeiro)
              .where(responsaveis_financeiros: { id: responsavel_id })
              .count
    end
  end
end

