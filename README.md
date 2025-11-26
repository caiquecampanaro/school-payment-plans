# Sistema de Planos de Pagamento - Kedu

Aplicação Ruby on Rails para gerenciar planos de pagamento de responsáveis financeiros, desenvolvida seguindo princípios SOLID, DRY e boas práticas de segurança.

## Tecnologias

- **Ruby**: 3.2.0
- **Rails**: 7.1.0
- **PostgreSQL**: 15
- **GraphQL**: graphql-ruby 2.0
- **Docker & Docker Compose**

## Estrutura do Projeto

### Modelos

- **ResponsavelFinanceiro**: Representa o responsável financeiro
- **CentroDeCusto**: Representa a natureza do plano (MATRICULA, MENSALIDADE, MATERIAL)
- **PlanoPagamento**: Plano vinculado a um responsável e centro de custo
- **Cobranca**: Parcelas do plano com valor, vencimento, método de pagamento e status
- **Pagamento**: Registro de recebimento de uma cobrança

### Services

- `PlanoPagamento::CriarService`: Lógica de criação de planos com cobranças
- `Cobranca::RegistrarPagamentoService`: Lógica de registro de pagamentos
- `Cobranca::GerarCodigoPagamentoService`: Geração de códigos de pagamento (BOLETO/PIX)

## Como Executar o Projeto

### Pré-requisitos

- Docker
- Docker Compose

### Passos

1. Clone o repositório:
```bash
git clone <repository-url>
cd school-payment-plans
```

2. Construa e inicie os containers:
```bash
docker-compose build
docker-compose up -d
```

3. Execute as migrations:
```bash
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
```

4. (Opcional) Popule o banco com dados iniciais:
```bash
docker-compose exec web rails db:seed
```

5. Configure o GraphQL (se necessário):
```bash
docker-compose exec web rails generate graphql:install
```

6. Acesse a aplicação:
```
http://localhost:3000
```

**Para desenvolvimento local (sem Docker):**

1. Certifique-se de ter Ruby 3.2.0 instalado:
```bash
rvm use 3.2.0
```

2. Instale as dependências:
```bash
bundle install
```

3. Configure as variáveis de ambiente:
```bash
cp .env.example .env
# Edite o .env se necessário
```

4. Crie o banco de dados e execute as migrações:
```bash
rails db:create
rails db:migrate
```

5. (Opcional) Popule o banco com dados iniciais:
```bash
rails db:seed
```

6. Inicie o servidor:
```bash
rails s
```

## Configuração do Banco de Dados

O banco de dados PostgreSQL é configurado automaticamente via Docker Compose. As credenciais padrão são:

- **Host**: db (dentro do Docker) ou localhost:5432 (fora do Docker)
- **Database**: school_payment_plans_development
- **Username**: postgres
- **Password**: postgres

Para alterar, edite o arquivo `docker-compose.yml` e `config/database.yml`.

## Listando Rotas Disponíveis

Para ver todas as rotas disponíveis no projeto, execute:

**Com Docker:**
```bash
docker-compose exec web rails routes
```

**Localmente:**
```bash
rails routes
```

### Rotas Principais

- **GET /responsaveis** - Listar todos os responsáveis financeiros
- **POST /responsaveis** - Criar responsável financeiro
- **GET /responsaveis/:id** - Ver responsável
- **GET /centros_de_custo** - Listar centros de custo
- **POST /centros_de_custo** - Criar centro de custo
- **GET /planos_pagamento** - Listar planos de pagamento
- **POST /planos_pagamento** - Criar plano de pagamento
- **GET /planos_pagamento/:id** - Ver plano de pagamento
- **GET /planos_pagamento/:id/total** - Valor total do plano
- **GET /responsaveis/:id/planos_pagamento** - Planos de um responsável
- **GET /responsaveis/:id/cobrancas** - Cobranças de um responsável
- **GET /responsaveis/:id/cobrancas/quantidade** - Quantidade de cobranças
- **POST /cobrancas/:id/pagamentos** - Registrar pagamento
- **POST /graphql** - Endpoint GraphQL

## Configuração do GraphQL

O GraphQL já está configurado no projeto. A estrutura inclui:

- **Schema**: `app/graphql/schema.rb`
- **Types**: `app/graphql/types/`
- **Controller**: `app/controllers/graphql_controller.rb`
- **Rota**: `POST /graphql`

### Estrutura GraphQL

O GraphQL foi configurado manualmente com os seguintes componentes:

- **Base Types**: `BaseObject`, `BaseInputObject`, `BaseEnum`
- **Types**: `ResponsavelFinanceiroType`, `CentroDeCustoType`, `PlanoPagamentoType`, `CobrancaType`, `PagamentoType`
- **Enums**: `MetodoPagamentoEnum`, `StatusCobrancaEnum`
- **Queries**: `QueryType` com todas as consultas
- **Mutations**: `MutationType` com todas as operações de escrita

### Testando o GraphQL

Você pode testar o GraphQL usando:

1. **cURL** (veja exemplos abaixo)
2. **GraphiQL** (se configurado)
3. **Postman** ou **Insomnia**
4. **Cliente GraphQL** de sua preferência

O endpoint GraphQL está disponível em: `POST http://localhost:3000/graphql`

## API REST

### Endpoints

#### Responsáveis Financeiros

**GET /responsaveis**
Lista todos os responsáveis financeiros.

```bash
curl http://localhost:3000/responsaveis
```

**POST /responsaveis**
Cria um responsável financeiro.

```bash
curl -X POST http://localhost:3000/responsaveis \
  -H "Content-Type: application/json" \
  -d '{
    "responsavel": {
      "nome": "João Silva",
      "identificador": "12345678900"
    }
  }'
```

**GET /responsaveis/:id**
Retorna detalhes de um responsável.

```bash
curl http://localhost:3000/responsaveis/1
```

#### Centros de Custo

**GET /centros-de-custo**
Lista todos os centros de custo ativos.

```bash
curl http://localhost:3000/centros-de-custo
```

**POST /centros-de-custo**
Cria um centro de custo.

```bash
curl -X POST http://localhost:3000/centros-de-custo \
  -H "Content-Type: application/json" \
  -d '{
    "centro_de_custo": {
      "nome": "Matrícula",
      "codigo": "MATRICULA",
      "tipo": "matricula",
      "ativo": true
    }
  }'
```

**PUT /centros-de-custo/:id**
Atualiza um centro de custo.

```bash
curl -X PUT http://localhost:3000/centros-de-custo/1 \
  -H "Content-Type: application/json" \
  -d '{
    "centro_de_custo": {
      "ativo": false
    }
  }'
```

**DELETE /centros-de-custo/:id**
Remove um centro de custo.

```bash
curl -X DELETE http://localhost:3000/centros-de-custo/1
```

#### Planos de Pagamento

**POST /planos-de-pagamento**
Cria um plano de pagamento com cobranças.

```bash
curl -X POST http://localhost:3000/planos-de-pagamento \
  -H "Content-Type: application/json" \
  -d '{
    "responsavel_id": 1,
    "centro_de_custo_id": 1,
    "cobrancas": [
      {
        "valor": 500.00,
        "data_vencimento": "2025-03-10",
        "metodo_pagamento": "BOLETO"
      },
      {
        "valor": 500.00,
        "data_vencimento": "2025-04-10",
        "metodo_pagamento": "PIX"
      }
    ]
  }'
```

**GET /planos-de-pagamento/:id**
Retorna detalhes de um plano.

```bash
curl http://localhost:3000/planos-de-pagamento/1
```

**GET /planos-de-pagamento/:id/total**
Retorna o valor total do plano.

```bash
curl http://localhost:3000/planos-de-pagamento/1/total
```

**GET /responsaveis/:id/planos-pagamento**
Lista planos de pagamento de um responsável.

```bash
curl http://localhost:3000/responsaveis/1/planos-pagamento
```

#### Cobranças

**GET /responsaveis/:id/cobrancas**
Lista cobranças de um responsável.

```bash
curl http://localhost:3000/responsaveis/1/cobrancas
```

**GET /responsaveis/:id/cobrancas/quantidade**
Retorna a quantidade de cobranças de um responsável.

```bash
curl http://localhost:3000/responsaveis/1/cobrancas/quantidade
```

**POST /cobrancas/:id/registrar_pagamento**
Registra pagamento de uma cobrança.

```bash
curl -X POST http://localhost:3000/cobrancas/1/registrar_pagamento \
  -H "Content-Type: application/json" \
  -d '{
    "pagamento": {
      "valor": 500.00,
      "data_pagamento": "2025-03-10"
    }
  }'
```

## GraphQL

### Endpoint

**POST /graphql**

### Queries

#### Consultar Plano de Pagamento

```graphql
query {
  planoPagamento(id: "1") {
    id
    valorTotal
    responsavelFinanceiro {
      nome
      identificador
    }
    centroDeCusto {
      nome
      codigo
    }
    cobrancas {
      id
      valor
      dataVencimento
      metodoPagamento
      status
      codigoPagamento
      vencida
    }
  }
}
```

#### Listar Planos de um Responsável

```graphql
query {
  planosPagamento(responsavelId: "1") {
    id
    valorTotal
    centroDeCusto {
      nome
    }
    cobrancas {
      valor
      status
    }
  }
}
```

#### Listar Cobranças de um Responsável

```graphql
query {
  cobrancas(responsavelId: "1") {
    id
    valor
    dataVencimento
    metodoPagamento
    status
    codigoPagamento
    vencida
    planoPagamento {
      id
    }
  }
}
```

#### Quantidade de Cobranças

```graphql
query {
  cobrancasQuantidade(responsavelId: "1")
}
```

### Mutations

#### Criar Plano de Pagamento

```graphql
mutation {
  criarPlanoPagamento(
    responsavelId: "1"
    centroDeCustoId: "1"
    cobrancas: [
      {
        valor: 500.00
        dataVencimento: "2025-03-10"
        metodoPagamento: BOLETO
      }
    ]
  ) {
    id
    valorTotal
    cobrancas {
      id
      codigoPagamento
    }
  }
}
```

#### Registrar Pagamento

```graphql
mutation {
  registrarPagamento(
    cobrancaId: "1"
    valor: 500.00
    dataPagamento: "2025-03-10"
  ) {
    id
    valor
    dataPagamento
    cobranca {
      status
    }
  }
}
```

#### Criar Responsável

```graphql
mutation {
  criarResponsavel(
    nome: "João Silva"
    identificador: "12345678900"
  ) {
    id
    nome
  }
}
```

#### Criar Centro de Custo

```graphql
mutation {
  criarCentroDeCusto(
    nome: "Matrícula"
    codigo: "MATRICULA"
    tipo: "matricula"
  ) {
    id
    nome
    codigo
  }
}
```

### Exemplo de Uso com cURL

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { planosPagamento { id valorTotal } }"
  }'
```

## Regras de Negócio

### Status da Cobrança

- **EMITIDA**: Cobrança criada, aguardando pagamento
- **PAGA**: Cobrança foi paga
- **CANCELADA**: Cobrança foi cancelada
- **VENCIDA**: Calculado dinamicamente quando `data_vencimento < hoje` e status não é PAGA nem CANCELADA

### Métodos de Pagamento

- **BOLETO**: Gera linha digitável simulada
- **PIX**: Gera código/chave PIX simulada

### Validações

- Não é permitido registrar pagamento em cobrança cancelada
- Valor total do plano = soma dos valores de todas as cobranças
- Todos os campos obrigatórios são validados

## Testes

### Executar Testes

```bash
docker-compose exec web bundle exec rspec
```

### Testes de Segurança

Os testes de segurança verificam:
- Proteção contra SQL Injection
- Proteção contra XSS
- Proteção contra XSRF/CSRF
- Validação de Strong Parameters
- Validação de inputs

```bash
docker-compose exec web bundle exec rspec spec/requests/security_spec.rb
```

## Estrutura de Diretórios

```
app/
  controllers/
    responsaveis_controller.rb
    centros_de_custo_controller.rb
    planos_pagamento_controller.rb
    cobrancas_controller.rb
    responsaveis/
      planos_pagamento_controller.rb
      cobrancas_controller.rb
    graphql_controller.rb
  models/
    responsavel_financeiro.rb
    centro_de_custo.rb
    plano_pagamento.rb
    cobranca.rb
    pagamento.rb
  services/
    plano_pagamento/
      criar_service.rb
    cobranca/
      registrar_pagamento_service.rb
      gerar_codigo_pagamento_service.rb
  graphql/
    schema.rb
    types/
      *.rb
config/
  routes.rb
  database.yml
db/
  migrate/
    *.rb
spec/
  requests/
    security_spec.rb
```

## Princípios Aplicados

- **SOLID**: Services com responsabilidade única, controllers delegando lógica
- **DRY**: Métodos reutilizáveis, services organizados
- **REST**: Uso correto de métodos HTTP (POST, GET, PUT, DELETE)
- **Segurança**: Strong parameters, validações, testes de segurança
- **Clean Code**: Nomes descritivos, código autoexplicativo

## Desenvolvimento

### Console Rails

```bash
docker-compose exec web rails console
```

### Logs

```bash
docker-compose logs -f web
```

### Parar os Containers

```bash
docker-compose down
```

### Reconstruir Containers

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Licença

Este projeto foi desenvolvido como parte de um desafio técnico.
# school-payment-plans
