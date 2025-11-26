class CreatePlanosPagamento < ActiveRecord::Migration[7.1]
  def change
    create_table :planos_pagamento do |t|
      t.references :responsavel_financeiro, null: false, foreign_key: true
      t.references :centro_de_custo, null: false, foreign_key: true

      t.timestamps
    end

    add_index :planos_pagamento, :responsavel_financeiro_id
    add_index :planos_pagamento, :centro_de_custo_id
  end
end

