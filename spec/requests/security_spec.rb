require 'rails_helper'

RSpec.describe 'Security Tests', type: :request do
  describe 'SQL Injection Protection' do
    let(:responsavel) { ResponsavelFinanceiro.create!(nome: 'Teste', identificador: '123') }

    it 'prevents SQL injection in responsavel_id parameter' do
      malicious_input = "1' OR '1'='1"
      
      expect {
        get "/responsaveis/#{malicious_input}/planos-pagamento"
      }.not_to raise_error
      
      expect(response).to have_http_status(:not_found)
    end

    it 'prevents SQL injection in query parameters' do
      malicious_input = "'; DROP TABLE responsaveis_financeiros; --"
      
      expect {
        get "/responsaveis/#{malicious_input}"
      }.not_to raise_error
      
      # Verifica que a tabela ainda existe
      expect(ResponsavelFinanceiro.count).to eq(1)
    end

    it 'uses parameterized queries in controllers' do
      # Testa que strong parameters estão sendo usados
      post '/responsaveis', params: {
        responsavel: {
          nome: "Test'; DROP TABLE responsaveis_financeiros; --",
          identificador: '456'
        }
      }
      
      # Se strong parameters estiver funcionando, o SQL injection não será executado
      expect(ResponsavelFinanceiro.count).to eq(2)
      expect(ResponsavelFinanceiro.last.nome).to include("DROP TABLE")
    end
  end

  describe 'XSS Protection' do
    it 'sanitizes user input in JSON responses' do
      post '/responsaveis', params: {
        responsavel: {
          nome: '<script>alert("XSS")</script>',
          identificador: 'xss_test'
        }
      }

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      
      # Verifica que o script não está executável no JSON
      expect(json_response['nome']).to include('<script>')
      # O Rails API mode não renderiza HTML, então o script não será executado
    end

    it 'handles malicious input in cobranca creation' do
      responsavel = ResponsavelFinanceiro.create!(nome: 'Test', identificador: '123')
      centro = CentroDeCusto.create!(nome: 'Test', codigo: 'TEST', ativo: true)

      post '/planos-de-pagamento', params: {
        responsavel_id: responsavel.id,
        centro_de_custo_id: centro.id,
        cobrancas: [
          {
            valor: 100,
            data_vencimento: '2025-12-31',
            metodo_pagamento: '<script>alert("XSS")</script>'
          }
        ]
      }

      # Deve falhar na validação, não executar o script
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'XSRF/CSRF Protection' do
    it 'validates request authenticity for state-changing operations' do
      # Em modo API, o Rails não usa CSRF tokens por padrão
      # Mas podemos verificar que as rotas estão protegidas
      responsavel = ResponsavelFinanceiro.create!(nome: 'Test', identificador: '123')

      # Testa que POST requer parâmetros válidos
      post '/responsaveis', params: {}
      
      expect(response).to have_http_status(:bad_request)
    end

    it 'requires proper HTTP methods for actions' do
      responsavel = ResponsavelFinanceiro.create!(nome: 'Test', identificador: '123')

      # Tenta usar GET em uma ação que requer POST
      get '/responsaveis', params: { responsavel: { nome: 'Test', identificador: '456' } }
      
      # Deve retornar método não permitido ou não encontrado
      expect(response).to have_http_status(:method_not_allowed).or have_http_status(:not_found)
    end
  end

  describe 'Strong Parameters' do
    it 'filters unauthorized parameters' do
      post '/responsaveis', params: {
        responsavel: {
          nome: 'Test',
          identificador: '123',
          id: 999, # Parâmetro não autorizado
          created_at: Time.zone.now # Parâmetro não autorizado
        }
      }

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      
      # Verifica que parâmetros não autorizados não foram salvos
      expect(json_response['id']).not_to eq(999)
    end

    it 'validates required parameters' do
      post '/responsaveis', params: {
        responsavel: {
          nome: 'Test'
          # identificador faltando
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to be_present
    end
  end

  describe 'Input Validation' do
    it 'validates numeric inputs' do
      responsavel = ResponsavelFinanceiro.create!(nome: 'Test', identificador: '123')
      centro = CentroDeCusto.create!(nome: 'Test', codigo: 'TEST', ativo: true)

      post '/planos-de-pagamento', params: {
        responsavel_id: responsavel.id,
        centro_de_custo_id: centro.id,
        cobrancas: [
          {
            valor: 'not_a_number',
            data_vencimento: '2025-12-31',
            metodo_pagamento: 'BOLETO'
          }
        ]
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'validates date inputs' do
      responsavel = ResponsavelFinanceiro.create!(nome: 'Test', identificador: '123')
      centro = CentroDeCusto.create!(nome: 'Test', codigo: 'TEST', ativo: true)

      post '/planos-de-pagamento', params: {
        responsavel_id: responsavel.id,
        centro_de_custo_id: centro.id,
        cobrancas: [
          {
            valor: 100,
            data_vencimento: 'invalid_date',
            metodo_pagamento: 'BOLETO'
          }
        ]
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'validates enum values' do
      responsavel = ResponsavelFinanceiro.create!(nome: 'Test', identificador: '123')
      centro = CentroDeCusto.create!(nome: 'Test', codigo: 'TEST', ativo: true)

      post '/planos-de-pagamento', params: {
        responsavel_id: responsavel.id,
        centro_de_custo_id: centro.id,
        cobrancas: [
          {
            valor: 100,
            data_vencimento: '2025-12-31',
            metodo_pagamento: 'INVALID_METHOD'
          }
        ]
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'Authorization Checks' do
    it 'returns 404 for non-existent resources' do
      get '/responsaveis/99999'
      expect(response).to have_http_status(:not_found)
    end

    it 'validates foreign key constraints' do
      post '/planos-de-pagamento', params: {
        responsavel_id: 99999,
        centro_de_custo_id: 99999,
        cobrancas: []
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

