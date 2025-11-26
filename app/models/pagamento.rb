class Pagamento < ApplicationRecord
  belongs_to :cobranca

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data_pagamento, presence: true
  validate :cobranca_nao_cancelada

  validate :valor_nao_excede_restante
  validate :cobranca_nao_cancelada
  after_create :atualizar_status_cobranca

  private

  def cobranca_nao_cancelada
    return unless cobranca&.cancelada?

    errors.add(:cobranca, 'não pode receber pagamento quando está cancelada')
  end

  def valor_nao_excede_restante
    return unless cobranca

    valor_restante = cobranca.valor_restante
    if valor > valor_restante
      errors.add(:valor, "não pode ser maior que o valor restante (R$ #{sprintf('%.2f', valor_restante).gsub('.', ',')})")
    end
  end

  def atualizar_status_cobranca
    cobranca.reload.atualizar_status_apos_pagamento
  end
end

