class CreatePagamentos < ActiveRecord::Migration[7.1]
  def change
    create_table :pagamentos do |t|
      t.references :cobranca, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data_pagamento, null: false

      t.timestamps
    end

    add_index :pagamentos, :cobranca_id
    add_index :pagamentos, :data_pagamento
  end
end

