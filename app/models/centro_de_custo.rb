class CentroDeCusto < ApplicationRecord
  self.table_name = 'centros_de_custo'

  has_many :planos_pagamento, dependent: :restrict_with_error

  validates :nome, presence: true
  validates :codigo, presence: true, uniqueness: true

  scope :ativos, -> { where(ativo: true) }

  enum tipo: {
    matricula: 'MATRICULA',
    mensalidade: 'MENSALIDADE',
    material: 'MATERIAL'
  }
end

