class CreateResponsaveisFinanceiros < ActiveRecord::Migration[7.1]
  def change
    create_table :responsaveis_financeiros do |t|
      t.string :nome, null: false
      t.string :identificador, null: false

      t.timestamps
    end

    add_index :responsaveis_financeiros, :identificador, unique: true
  end
end

