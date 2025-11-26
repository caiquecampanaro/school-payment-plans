class ResponsavelFinanceiro < ApplicationRecord
  self.table_name = 'responsaveis_financeiros'

  has_many :planos_pagamento, dependent: :destroy
  has_many :cobrancas, -> { distinct }, through: :planos_pagamento

  validates :nome, presence: true
  validates :identificador, presence: true, uniqueness: true

  def total_cobrancas
    cobrancas.count
  end

  def total_valor_cobrancas
    cobrancas.sum(:valor) || 0
  end

  def total_valor_pago
    cobrancas.joins(:pagamentos).sum('pagamentos.valor') || 0
  end

  def total_valor_pendente
    total_valor_cobrancas - total_valor_pago
  end

  def cobrancas_pagas
    cobrancas.where(status: 'PAGA')
  end

  def cobrancas_vencidas
    cobrancas.where(status: 'EMITIDA')
             .where('data_vencimento < ?', Time.zone.now.to_date)
  end

  def cobrancas_pendentes
    cobrancas.where(status: 'EMITIDA')
             .where('data_vencimento >= ?', Time.zone.now.to_date)
  end

  def valor_cobrancas_vencidas
    cobrancas_vencidas.sum(:valor) - cobrancas_vencidas.joins(:pagamentos).sum('pagamentos.valor')
  end

  def valor_cobrancas_pendentes
    cobrancas_pendentes.sum(:valor) - cobrancas_pendentes.joins(:pagamentos).sum('pagamentos.valor')
  end
end


