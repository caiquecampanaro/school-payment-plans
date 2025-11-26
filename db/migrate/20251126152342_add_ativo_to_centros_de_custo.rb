class AddAtivoToCentrosDeCusto < ActiveRecord::Migration[7.1]
  def change
    add_column :centros_de_custo, :ativo, :boolean, default: true, null: false
  end
end
