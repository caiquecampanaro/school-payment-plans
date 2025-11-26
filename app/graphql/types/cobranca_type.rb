module Types
  class CobrancaType < BaseObject
    field :id, ID, null: false
    field :valor, Float, null: false
    field :data_vencimento, GraphQL::Types::ISO8601Date, null: false
    field :metodo_pagamento, MetodoPagamentoEnum, null: false
    field :status, StatusCobrancaEnum, null: false
    field :codigo_pagamento, String, null: true
    field :vencida, Boolean, null: false
    field :plano_pagamento, PlanoPagamentoType, null: false

    def vencida
      object.vencida?
    end
  end
end

