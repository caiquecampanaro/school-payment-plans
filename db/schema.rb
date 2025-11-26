# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_11_26_152342) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "centros_de_custo", force: :cascade do |t|
    t.string "nome", limit: 255, null: false
    t.string "codigo", limit: 50, null: false
    t.string "tipo", default: "customizado", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo", default: true, null: false
    t.index ["codigo"], name: "index_centros_de_custo_on_codigo", unique: true
    t.index ["nome"], name: "index_centros_de_custo_on_nome"
    t.index ["tipo"], name: "index_centros_de_custo_on_tipo"
  end

  create_table "cobrancas", force: :cascade do |t|
    t.bigint "plano_de_pagamento_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data_vencimento", null: false
    t.string "metodo_pagamento", null: false
    t.string "status", default: "emitida", null: false
    t.string "codigo_pagamento", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo_pagamento"], name: "index_cobrancas_on_codigo_pagamento", unique: true
    t.index ["data_vencimento"], name: "index_cobrancas_on_data_vencimento"
    t.index ["metodo_pagamento"], name: "index_cobrancas_on_metodo_pagamento"
    t.index ["plano_de_pagamento_id"], name: "index_cobrancas_on_plano_de_pagamento_id"
    t.index ["status"], name: "index_cobrancas_on_status"
  end

  create_table "pagamentos", force: :cascade do |t|
    t.bigint "cobranca_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data_pagamento", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cobranca_id"], name: "index_pagamentos_on_cobranca_id"
    t.index ["data_pagamento"], name: "index_pagamentos_on_data_pagamento"
  end

  create_table "planos_de_pagamento", force: :cascade do |t|
    t.bigint "responsavel_financeiro_id", null: false
    t.bigint "centro_de_custo_id", null: false
    t.decimal "valor_total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["centro_de_custo_id"], name: "index_planos_de_pagamento_on_centro_de_custo_id"
    t.index ["responsavel_financeiro_id"], name: "index_planos_de_pagamento_on_responsavel_financeiro_id"
  end

  create_table "responsaveis_financeiros", force: :cascade do |t|
    t.string "nome", limit: 255, null: false
    t.string "identificador", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identificador"], name: "index_responsaveis_financeiros_on_identificador", unique: true
    t.index ["nome"], name: "index_responsaveis_financeiros_on_nome"
  end

  add_foreign_key "cobrancas", "planos_de_pagamento", column: "plano_de_pagamento_id"
  add_foreign_key "pagamentos", "cobrancas"
  add_foreign_key "planos_de_pagamento", "centros_de_custo"
  add_foreign_key "planos_de_pagamento", "responsaveis_financeiros", column: "responsavel_financeiro_id"
end
