class ResponsavelFinanceiro < ApplicationRecord
  self.table_name = 'responsaveis_financeiros'

  has_many :planos_pagamento, dependent: :destroy
  has_many :cobrancas, through: :planos_pagamento

  validates :nome, presence: true
  validates :identificador, presence: true, uniqueness: true

  def total_cobrancas
    Cobranca.joins(plano_pagamento: :responsavel_financeiro)
            .where(responsaveis_financeiros: { id: id })
            .count
  end

  def total_valor_cobrancas
    Cobranca.joins(plano_pagamento: :responsavel_financeiro)
            .where(responsaveis_financeiros: { id: id })
            .sum(:valor) || 0
  end

  def total_valor_pago
    Pagamento.joins(cobranca: { plano_pagamento: :responsavel_financeiro })
             .where(responsaveis_financeiros: { id: id })
             .sum(:valor) || 0
  end

  def total_valor_pendente
    total_valor_cobrancas - total_valor_pago
  end

  def cobrancas_pagas
    Cobranca.joins(plano_pagamento: :responsavel_financeiro)
            .where(responsaveis_financeiros: { id: id }, status: 'PAGA')
  end

  def cobrancas_vencidas
    Cobranca.joins(plano_pagamento: :responsavel_financeiro)
            .where(responsaveis_financeiros: { id: id })
            .where(status: 'EMITIDA')
            .where('cobrancas.data_vencimento < ?', Time.zone.now.to_date)
  end

  def cobrancas_pendentes
    Cobranca.joins(plano_pagamento: :responsavel_financeiro)
            .where(responsaveis_financeiros: { id: id })
            .where(status: 'EMITIDA')
            .where('cobrancas.data_vencimento >= ?', Time.zone.now.to_date)
  end

  def valor_cobrancas_vencidas
    cobrancas_vencidas.sum(:valor) - 
    Pagamento.joins(cobranca: { plano_pagamento: :responsavel_financeiro })
             .where(responsaveis_financeiros: { id: id })
             .where('cobrancas.status = ? AND cobrancas.data_vencimento < ?', 'EMITIDA', Time.zone.now.to_date)
             .sum(:valor) || 0
  end

  def valor_cobrancas_pendentes
    cobrancas_pendentes.sum(:valor) - 
    Pagamento.joins(cobranca: { plano_pagamento: :responsavel_financeiro })
             .where(responsaveis_financeiros: { id: id })
             .where('cobrancas.status = ? AND cobrancas.data_vencimento >= ?', 'EMITIDA', Time.zone.now.to_date)
             .sum(:valor) || 0
  end
end


