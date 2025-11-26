Rails.application.routes.draw do
  root 'dashboard#index'
  get 'dashboard', to: 'dashboard#index'
  
  # REST API
  resources :responsaveis, only: [:index, :create, :show, :new] do
    resources :planos_pagamento, only: [:index], controller: 'responsaveis/planos_pagamento'
    resources :cobrancas, only: [:index], controller: 'responsaveis/cobrancas' do
      collection do
        get :quantidade
      end
    end
  end

  resources :centros_de_custo, only: [:index, :show, :create, :update, :destroy, :new, :edit]

  resources :planos_pagamento, only: [:index, :show, :create, :new] do
    member do
      get :total
    end
  end

  resources :cobrancas, only: [] do
    member do
      get 'pagamentos/new', to: 'cobrancas#new_pagamento', as: 'new_pagamento'
      post 'pagamentos', to: 'cobrancas#registrar_pagamento'
    end
  end

  # GraphQL endpoint
  post '/graphql', to: 'graphql#execute'
  get '/graphql', to: 'graphql#graphiql'
end
