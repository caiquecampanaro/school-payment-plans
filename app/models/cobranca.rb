class Cobranca < ApplicationRecord
  belongs_to :plano_pagamento, foreign_key: 'plano_de_pagamento_id'
  has_many :pagamentos, dependent: :destroy

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data_vencimento, presence: true
  validates :metodo_pagamento, presence: true
  validates :status, presence: true

  enum metodo_pagamento: {
    boleto: 'BOLETO',
    pix: 'PIX'
  }

  enum status: {
    emitida: 'EMITIDA',
    paga: 'PAGA',
    cancelada: 'CANCELADA'
  }

  before_create :gerar_codigo_pagamento

  def vencida?
    return false if paga? || cancelada?
    Time.zone.now > data_vencimento
  end

  def valor_pago
    pagamentos.sum(:valor)
  end

  def valor_restante
    valor - valor_pago
  end

  def pago_totalmente?
    valor_pago >= valor
  end

  def atualizar_status_apos_pagamento
    return if cancelada?
    
    if pago_totalmente?
      update(status: :paga) unless paga?
    elsif status == 'PAGA'
      # Se estava paga mas agora tem valor restante, volta para emitida
      update(status: :emitida)
    end
  end

  private

  def gerar_codigo_pagamento
    self.codigo_pagamento = CobrancaServices::GerarCodigoPagamentoService.new(self).call
  end
end

