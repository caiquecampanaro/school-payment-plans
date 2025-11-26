module Types
  class MutationType < BaseObject
    field :criar_plano_pagamento, PlanoPagamentoType, null: true do
      argument :responsavel_id, ID, required: true
      argument :centro_de_custo_id, ID, required: true
      argument :cobrancas, [CobrancaInput], required: true
    end

    field :registrar_pagamento, PagamentoType, null: true do
      argument :cobranca_id, ID, required: true
      argument :valor, Float, required: false
      argument :data_pagamento, GraphQL::Types::ISO8601Date, required: false
    end

    field :criar_responsavel, ResponsavelFinanceiroType, null: true do
      argument :nome, String, required: true
      argument :identificador, String, required: true
    end

    field :criar_centro_de_custo, CentroDeCustoType, null: true do
      argument :nome, String, required: true
      argument :codigo, String, required: true
      argument :tipo, String, required: false
    end

    def criar_plano_pagamento(responsavel_id:, centro_de_custo_id:, cobrancas:)
      params = {
        responsavel_id: responsavel_id.to_i,
        centro_de_custo_id: centro_de_custo_id.to_i,
        cobrancas: cobrancas.map do |c|
          {
            valor: c[:valor] || c['valor'],
            data_vencimento: c[:data_vencimento] || c['data_vencimento'],
            metodo_pagamento: (c[:metodo_pagamento] || c['metodo_pagamento'])&.downcase
          }
        end
      }

      service = PlanoPagamentoServices::CriarService.new(params)
      service.call
    end

    def registrar_pagamento(cobranca_id:, valor: nil, data_pagamento: nil)
      cobranca = Cobranca.find(cobranca_id)
      params = {}
      params[:valor] = valor if valor
      params[:data_pagamento] = data_pagamento if data_pagamento

      service = CobrancaServices::RegistrarPagamentoService.new(cobranca, params)
      service.call
    end

    def criar_responsavel(nome:, identificador:)
      ResponsavelFinanceiro.create(nome: nome, identificador: identificador)
    end

    def criar_centro_de_custo(nome:, codigo:, tipo: nil)
      CentroDeCusto.create(nome: nome, codigo: codigo, tipo: tipo)
    end
  end
end

