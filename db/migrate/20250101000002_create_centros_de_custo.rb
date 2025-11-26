class CreateCentrosDeCusto < ActiveRecord::Migration[7.1]
  def change
    create_table :centros_de_custo do |t|
      t.string :nome, null: false
      t.string :codigo, null: false
      t.boolean :ativo, default: true, null: false
      t.string :tipo

      t.timestamps
    end

    add_index :centros_de_custo, :codigo, unique: true
    add_index :centros_de_custo, :ativo
  end
end

