# Limpar dados existentes
Pagamento.destroy_all
Cobranca.destroy_all
PlanoPagamento.destroy_all
CentroDeCusto.destroy_all
ResponsavelFinanceiro.destroy_all

# Criar centros de custo padrão
centro_matricula = CentroDeCusto.create!(
  nome: 'Matrícula',
  codigo: 'MATRICULA',
  tipo: 'matricula',
  ativo: true
)

centro_mensalidade = CentroDeCusto.create!(
  nome: 'Mensalidade',
  codigo: 'MENSALIDADE',
  tipo: 'mensalidade',
  ativo: true
)

centro_material = CentroDeCusto.create!(
  nome: 'Material',
  codigo: 'MATERIAL',
  tipo: 'material',
  ativo: true
)

# Criar responsáveis financeiros
responsavel1 = ResponsavelFinanceiro.create!(
  nome: 'João Silva',
  identificador: '12345678900'
)

responsavel2 = ResponsavelFinanceiro.create!(
  nome: 'Maria Santos',
  identificador: '98765432100'
)

# Criar planos de pagamento
plano1 = PlanoPagamento.create!(
  responsavel_financeiro: responsavel1,
  centro_de_custo: centro_matricula
)

plano2 = PlanoPagamento.create!(
  responsavel_financeiro: responsavel1,
  centro_de_custo: centro_mensalidade
)

# Criar cobranças para plano1
Cobranca.create!(
  plano_pagamento: plano1,
  valor: 500.00,
  data_vencimento: Date.today + 10.days,
  metodo_pagamento: 'boleto',
  status: 'emitida'
)

Cobranca.create!(
  plano_pagamento: plano1,
  valor: 500.00,
  data_vencimento: Date.today + 40.days,
  metodo_pagamento: 'pix',
  status: 'emitida'
)

# Criar cobranças para plano2 (mensalidade - 12 parcelas)
12.times do |i|
  Cobranca.create!(
    plano_pagamento: plano2,
    valor: 300.00,
    data_vencimento: Date.today.beginning_of_month + (i + 1).months,
    metodo_pagamento: i.even? ? 'boleto' : 'pix',
    status: i < 2 ? 'paga' : 'emitida'
  )
end

puts "Seeds criados com sucesso!"
puts "- #{CentroDeCusto.count} centros de custo"
puts "- #{ResponsavelFinanceiro.count} responsáveis financeiros"
puts "- #{PlanoPagamento.count} planos de pagamento"
puts "- #{Cobranca.count} cobranças"
