module CobrancaServices
  class RegistrarPagamentoService
    attr_reader :cobranca, :params, :pagamento, :errors

    def initialize(cobranca, params)
      @cobranca = cobranca
      @params = params
      @errors = []
    end

    def call
      return @cobranca unless validar_cobranca

      ActiveRecord::Base.transaction do
        criar_pagamento
      end

      @pagamento
    rescue StandardError => e
      @errors << e.message
      nil
    end

    def success?
      @errors.empty? && @pagamento&.persisted?
    end

    private

    def validar_cobranca
      if @cobranca.cancelada?
        @errors << 'Não é permitido registrar pagamento em cobrança cancelada'
        return false
      end

      true
    end

    def criar_pagamento
      valor_pagamento = params[:valor] || @cobranca.valor_restante
      
      if valor_pagamento > @cobranca.valor_restante
        @errors << "O valor do pagamento (R$ #{sprintf('%.2f', valor_pagamento).gsub('.', ',')}) não pode ser maior que o valor restante (R$ #{sprintf('%.2f', @cobranca.valor_restante).gsub('.', ',')})"
        raise ActiveRecord::Rollback
      end

      @pagamento = @cobranca.pagamentos.build(
        valor: valor_pagamento,
        data_pagamento: params[:data_pagamento] || Time.zone.now.to_date
      )

      unless @pagamento.save
        @errors.concat(@pagamento.errors.full_messages)
        raise ActiveRecord::Rollback
      end
    end
  end
end

