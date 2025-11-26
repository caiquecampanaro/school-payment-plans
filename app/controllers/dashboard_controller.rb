class DashboardController < ApplicationController
  def index
    @responsaveis = ResponsavelFinanceiro.includes(planos_pagamento: { cobrancas: :pagamentos }).all.order(:nome)
    
    # Estatísticas gerais
    @total_responsaveis = @responsaveis.count
    @total_cobrancas = Cobranca.count
    @total_valor_cobrancas = Cobranca.sum(:valor) || 0
    @total_valor_pago = Pagamento.sum(:valor) || 0
    @total_valor_pendente = @total_valor_cobrancas - @total_valor_pago
    
    # Cobranças vencidas
    @cobrancas_vencidas = Cobranca.where(status: 'EMITIDA')
                                   .where('data_vencimento < ?', Time.zone.now.to_date)
    @total_valor_vencido = (@cobrancas_vencidas.sum(:valor) || 0) - 
                          (@cobrancas_vencidas.joins(:pagamentos).sum('pagamentos.valor') || 0)
    
    # Cobranças pendentes (não vencidas)
    @cobrancas_pendentes = Cobranca.where(status: 'EMITIDA')
                                    .where('data_vencimento >= ?', Time.zone.now.to_date)
    @total_valor_pendente_futuro = (@cobrancas_pendentes.sum(:valor) || 0) - 
                                   (@cobrancas_pendentes.joins(:pagamentos).sum('pagamentos.valor') || 0)
    
    # Cobranças pagas
    @cobrancas_pagas = Cobranca.where(status: 'PAGA')
    @total_cobrancas_pagas = @cobrancas_pagas.count
    
    respond_to do |format|
      format.html
      format.json { render json: {
        total_responsaveis: @total_responsaveis,
        total_cobrancas: @total_cobrancas,
        total_valor_cobrancas: @total_valor_cobrancas,
        total_valor_pago: @total_valor_pago,
        total_valor_pendente: @total_valor_pendente,
        total_valor_vencido: @total_valor_vencido,
        total_valor_pendente_futuro: @total_valor_pendente_futuro,
        total_cobrancas_pagas: @total_cobrancas_pagas
      } }
    end
  end
end
