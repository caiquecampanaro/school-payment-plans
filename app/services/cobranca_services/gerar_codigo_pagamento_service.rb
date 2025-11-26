require 'securerandom'

module CobrancaServices
  class GerarCodigoPagamentoService
    attr_reader :cobranca

    def initialize(cobranca)
      @cobranca = cobranca
    end

    def call
      case @cobranca.metodo_pagamento
      when 'boleto'
        gerar_codigo_boleto
      when 'pix'
        gerar_codigo_pix
      else
        gerar_codigo_generico
      end
    end

    private

    def gerar_codigo_boleto
      # Simula linha digitável de boleto (44 dígitos)
      "#{rand(10000..99999)}.#{rand(10000..99999)} #{rand(10000..99999)}.#{rand(100000..999999)} #{rand(10000..99999)}.#{rand(100000..999999)} #{rand(1..9)} #{rand(10000000000000..99999999999999)}"
    end

    def gerar_codigo_pix
      # Simula chave PIX (32 caracteres alfanuméricos)
      SecureRandom.alphanumeric(32).upcase
    end

    def gerar_codigo_generico
      SecureRandom.uuid
    end
  end
end

