class ResponsaveisController < ApplicationController
  before_action :set_responsavel, only: [:show]

  def index
    @responsaveis = ResponsavelFinanceiro.all.order(:nome)
    respond_to do |format|
      format.html
      format.json { render json: @responsaveis }
    end
  end

  def create
    @responsavel = ResponsavelFinanceiro.new(responsavel_params)

    if @responsavel.save
      respond_to do |format|
        format.html { redirect_to responsaveis_path, notice: 'Responsável criado com sucesso!' }
        format.json { render json: @responsavel, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @responsavel.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def new
    @responsavel = ResponsavelFinanceiro.new
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @responsavel }
    end
  end

  private

  def set_responsavel
    @responsavel = ResponsavelFinanceiro.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Responsável financeiro não encontrado' }, status: :not_found
  end

  def responsavel_params
    params.require(:responsavel).permit(:nome, :identificador)
  end
end

