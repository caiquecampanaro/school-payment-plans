module PlanoPagamentoServices
  class CriarService
    attr_reader :params, :plano_pagamento, :errors

    def initialize(params)
      @params = params
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        criar_plano
        criar_cobrancas if @plano_pagamento.persisted?
      end

      @plano_pagamento
    rescue StandardError => e
      @errors << e.message
      @plano_pagamento
    end

    def success?
      @errors.empty? && @plano_pagamento&.persisted?
    end

    private

    def criar_plano
      @plano_pagamento = ::PlanoPagamento.new(
        responsavel_financeiro_id: params[:responsavel_id],
        centro_de_custo_id: params[:centro_de_custo_id]
      )

      unless @plano_pagamento.save
        @errors.concat(@plano_pagamento.errors.full_messages)
        raise ActiveRecord::Rollback
      end
    end

    def criar_cobrancas
      # Se foi solicitado criar parcelas, usar o service de parcelas
      if params[:criar_parcelas] == '1' || params[:criar_parcelas] == true
        criar_parcelas_automaticas
      elsif params[:cobrancas].present?
        criar_cobrancas_manuais
      end
    end

    def criar_parcelas_automaticas
      begin
        parcelas_service = PlanoPagamentoServices::CriarParcelasService.new(
          valor_total: params[:valor_total_parcelas],
          quantidade_parcelas: params[:quantidade_parcelas],
          data_primeiro_vencimento: params[:data_primeiro_vencimento],
          metodo_pagamento: params[:metodo_pagamento_parcelas],
          intervalo_dias: params[:intervalo_dias] || 30
        )

        cobrancas_params = parcelas_service.call

        if cobrancas_params.empty?
          @errors << "Não foi possível gerar as parcelas. Verifique os parâmetros informados."
          raise ActiveRecord::Rollback
        end

        cobrancas_params.each do |cobranca_params|
          # Converte método de pagamento para minúsculo (enum espera boleto/pix)
          metodo = cobranca_params[:metodo_pagamento]&.downcase
          
          # Valida se o método é válido
          unless ['boleto', 'pix'].include?(metodo)
            @errors << "Método de pagamento inválido: #{cobranca_params[:metodo_pagamento]}. Use BOLETO ou PIX."
            raise ActiveRecord::Rollback
          end
          
          cobranca = @plano_pagamento.cobrancas.build(
            valor: cobranca_params[:valor],
            data_vencimento: cobranca_params[:data_vencimento],
            metodo_pagamento: metodo,
            status: 'emitida' # Define status inicial
          )

          unless cobranca.save
            @errors.concat(cobranca.errors.full_messages)
            raise ActiveRecord::Rollback
          end
        end
      rescue ArgumentError => e
        @errors << e.message
        raise ActiveRecord::Rollback
      rescue StandardError => e
        @errors << "Erro ao criar parcelas: #{e.message}"
        raise ActiveRecord::Rollback
      end
    end

    def criar_cobrancas_manuais
      # Filtra apenas cobranças com valores preenchidos (remove campos vazios)
      cobrancas_validas = params[:cobrancas].select do |cobranca_params|
        cobranca_params = cobranca_params.to_h if cobranca_params.respond_to?(:to_h)
        valor = cobranca_params[:valor] || cobranca_params['valor']
        data = cobranca_params[:data_vencimento] || cobranca_params['data_vencimento']
        valor.present? && data.present?
      end

      return if cobrancas_validas.empty?

      cobrancas_validas.each do |cobranca_params|
        cobranca_params = cobranca_params.to_h if cobranca_params.respond_to?(:to_h)
        metodo = cobranca_params[:metodo_pagamento] || cobranca_params['metodo_pagamento']
        # Converte para minúsculo para corresponder ao enum (boleto/pix)
        metodo_normalizado = metodo&.downcase
        
        cobranca = @plano_pagamento.cobrancas.build(
          valor: cobranca_params[:valor] || cobranca_params['valor'],
          data_vencimento: cobranca_params[:data_vencimento] || cobranca_params['data_vencimento'],
          metodo_pagamento: metodo_normalizado,
          status: 'emitida' # Define status inicial
        )

        unless cobranca.save
          @errors.concat(cobranca.errors.full_messages)
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end

