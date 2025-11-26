class PlanosPagamentoController < ApplicationController
  before_action :set_plano_pagamento, only: [:show, :total]

  def index
    @planos_pagamento = PlanoPagamento.includes(:responsavel_financeiro, :centro_de_custo, :cobrancas).order(created_at: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @planos_pagamento.as_json(
        include: {
          responsavel_financeiro: { only: [:id, :nome, :identificador] },
          centro_de_custo: { only: [:id, :nome, :codigo, :tipo] },
          cobrancas: { only: [:id, :valor, :data_vencimento, :metodo_pagamento, :status, :codigo_pagamento] }
      }) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @plano_pagamento.as_json(
        include: {
          responsavel_financeiro: { only: [:id, :nome, :identificador] },
          centro_de_custo: { only: [:id, :nome, :codigo, :tipo] },
          cobrancas: { only: [:id, :valor, :data_vencimento, :metodo_pagamento, :status, :codigo_pagamento] }
        },
        methods: [:valor_total]
      ) }
    end
  end

  def new
    @plano_pagamento = PlanoPagamento.new
    @responsaveis = ResponsavelFinanceiro.all.order(:nome)
    @centros_de_custo = CentroDeCusto.ativos.order(:nome)
    @cobrancas = [@plano_pagamento.cobrancas.build]
  end

  def total
    respond_to do |format|
      format.html { redirect_to plano_pagamento_path(@plano_pagamento) }
      format.json { render json: { valor_total: @plano_pagamento.valor_total } }
    end
  end

  def create
    # Validar quantidade de parcelas se estiver criando parcelas
    if params[:criar_parcelas] == '1' || params[:criar_parcelas] == true
      parcelas_permitidas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18]
      quantidade = params[:quantidade_parcelas].to_i
      unless parcelas_permitidas.include?(quantidade)
        @responsaveis = ResponsavelFinanceiro.all.order(:nome)
        @centros_de_custo = CentroDeCusto.ativos.order(:nome)
        respond_to do |format|
          format.html { 
            flash.now[:alert] = "Quantidade de parcelas inválida. Valores permitidos: 1 até 12 ou 18."
            render :new, status: :unprocessable_entity 
          }
          format.json { render json: { errors: ["Quantidade de parcelas inválida. Valores permitidos: 1 até 12 ou 18."] }, status: :unprocessable_entity }
        end
        return
      end
    end

    service = PlanoPagamentoServices::CriarService.new(plano_pagamento_params)
    @plano_pagamento = service.call

    if service.success?
      respond_to do |format|
        format.html { redirect_to plano_pagamento_path(@plano_pagamento), notice: 'Plano de pagamento criado com sucesso!' }
        format.json { render json: @plano_pagamento.as_json(
          include: {
            responsavel_financeiro: { only: [:id, :nome, :identificador] },
            centro_de_custo: { only: [:id, :nome, :codigo, :tipo] },
            cobrancas: { only: [:id, :valor, :data_vencimento, :metodo_pagamento, :status, :codigo_pagamento] }
          },
          methods: [:valor_total]
        ), status: :created }
      end
    else
      @plano_pagamento = PlanoPagamento.new
      @service_errors = service.errors
      @responsaveis = ResponsavelFinanceiro.all.order(:nome)
      @centros_de_custo = CentroDeCusto.ativos.order(:nome)
      respond_to do |format|
        format.html { 
          flash.now[:alert] = "Erro ao criar plano de pagamento: #{service.errors.join(', ')}"
          render :new, status: :unprocessable_entity 
        }
        format.json { render json: { errors: service.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_plano_pagamento
    @plano_pagamento = PlanoPagamento.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Plano de pagamento não encontrado' }, status: :not_found
  end

  def plano_pagamento_params
    params.permit(:responsavel_id, :centro_de_custo_id, 
                  :criar_parcelas, :valor_total_parcelas, :quantidade_parcelas, 
                  :data_primeiro_vencimento, :metodo_pagamento_parcelas, :intervalo_dias,
                  cobrancas: [:valor, :data_vencimento, :metodo_pagamento])
  end
end

