class PlanoPagamento < ApplicationRecord
  self.table_name = 'planos_de_pagamento'

  belongs_to :responsavel_financeiro
  belongs_to :centro_de_custo
  has_many :cobrancas, foreign_key: 'plano_de_pagamento_id', dependent: :destroy

  validates :responsavel_financeiro_id, presence: true
  validates :centro_de_custo_id, presence: true

  def valor_total
    cobrancas.sum(:valor)
  end
end

