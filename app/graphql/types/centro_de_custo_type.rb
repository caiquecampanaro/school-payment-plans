module Types
  class CentroDeCustoType < BaseObject
    field :id, ID, null: false
    field :nome, String, null: false
    field :codigo, String, null: false
    field :ativo, Boolean, null: false
    field :tipo, String, null: true
  end
end

