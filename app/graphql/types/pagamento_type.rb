module Types
  class PagamentoType < BaseObject
    field :id, ID, null: false
    field :valor, Float, null: false
    field :data_pagamento, GraphQL::Types::ISO8601Date, null: false
    field :cobranca, CobrancaType, null: false
  end
end

