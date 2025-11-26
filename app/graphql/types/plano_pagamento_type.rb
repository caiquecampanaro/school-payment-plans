module Types
  class PlanoPagamentoType < BaseObject
    field :id, ID, null: false
    field :valor_total, Float, null: false
    field :responsavel_financeiro, ResponsavelFinanceiroType, null: false
    field :centro_de_custo, CentroDeCustoType, null: false
    field :cobrancas, [CobrancaType], null: true

    def valor_total
      object.valor_total
    end
  end
end

