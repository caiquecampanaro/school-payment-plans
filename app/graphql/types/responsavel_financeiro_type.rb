module Types
  class ResponsavelFinanceiroType < BaseObject
    field :id, ID, null: false
    field :nome, String, null: false
    field :identificador, String, null: false
    field :planos_pagamento, [PlanoPagamentoType], null: true
  end
end

