class CreateCobrancas < ActiveRecord::Migration[7.1]
  def change
    create_table :cobrancas do |t|
      t.references :plano_pagamento, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data_vencimento, null: false
      t.string :metodo_pagamento, null: false
      t.string :status, null: false, default: 'EMITIDA'
      t.string :codigo_pagamento

      t.timestamps
    end

    add_index :cobrancas, :plano_pagamento_id
    add_index :cobrancas, :data_vencimento
    add_index :cobrancas, :status
    add_index :cobrancas, :codigo_pagamento
  end
end

