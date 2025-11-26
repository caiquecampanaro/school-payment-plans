module PlanoPagamentoServices
  class CriarParcelasService
    attr_reader :valor_total, :quantidade_parcelas, :data_primeiro_vencimento, :metodo_pagamento, :intervalo_dias

    def initialize(valor_total:, quantidade_parcelas:, data_primeiro_vencimento:, metodo_pagamento:, intervalo_dias: 30)
      @valor_total = valor_total.to_f
      @quantidade_parcelas = quantidade_parcelas.to_i
      @data_primeiro_vencimento = data_primeiro_vencimento.is_a?(String) ? Date.parse(data_primeiro_vencimento) : data_primeiro_vencimento
      @metodo_pagamento = metodo_pagamento&.downcase
      @intervalo_dias = intervalo_dias.to_i
    end

    def call
      # Valida quantidade de parcelas permitidas (1-12 ou 18)
      parcelas_permitidas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18]
      unless parcelas_permitidas.include?(quantidade_parcelas)
        raise ArgumentError, "Quantidade de parcelas inválida. Valores permitidos: 1 até 12 ou 18."
      end
      return [] if valor_total <= 0

      valor_parcela = (valor_total / quantidade_parcelas).round(2)
      ultima_parcela_valor = valor_total - (valor_parcela * (quantidade_parcelas - 1))

      cobrancas = []
      quantidade_parcelas.times do |index|
        data_vencimento = data_primeiro_vencimento + (intervalo_dias * index).days
        valor = (index == quantidade_parcelas - 1) ? ultima_parcela_valor : valor_parcela

        cobrancas << {
          valor: valor,
          data_vencimento: data_vencimento.strftime('%Y-%m-%d'),
          metodo_pagamento: metodo_pagamento
        }
      end

      cobrancas
    end
  end
end

