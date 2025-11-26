module Types
  class CobrancaInput < BaseInputObject
    argument :valor, Float, required: true
    argument :data_vencimento, GraphQL::Types::ISO8601Date, required: true
    argument :metodo_pagamento, MetodoPagamentoEnum, required: true
  end
end

