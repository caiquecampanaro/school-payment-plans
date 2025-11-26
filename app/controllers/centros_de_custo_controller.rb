class CentrosDeCustoController < ApplicationController
  before_action :set_centro_de_custo, only: [:show, :edit, :update, :destroy]

  def index
    @centros_de_custo = CentroDeCusto.all.order(:nome)
    respond_to do |format|
      format.html
      format.json { render json: @centros_de_custo }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @centro_de_custo }
    end
  end

  def new
    @centro_de_custo = CentroDeCusto.new
  end

  def edit
  end

  def create
    @centro_de_custo = CentroDeCusto.new(centro_de_custo_params)

    if @centro_de_custo.save
      respond_to do |format|
        format.html { redirect_to centro_de_custo_path(@centro_de_custo), notice: 'Centro de custo criado com sucesso!' }
        format.json { render json: @centro_de_custo, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @centro_de_custo.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @centro_de_custo.update(centro_de_custo_params)
      respond_to do |format|
        format.html { redirect_to centro_de_custo_path(@centro_de_custo), notice: 'Centro de custo atualizado com sucesso!' }
        format.json { render json: @centro_de_custo }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @centro_de_custo.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @centro_de_custo.planos_pagamento.any?
      respond_to do |format|
        format.html { redirect_to centros_de_custo_path, alert: 'Não é possível excluir centro de custo com planos de pagamento associados' }
        format.json { render json: { error: 'Não é possível excluir centro de custo com planos de pagamento associados' }, status: :unprocessable_entity }
      end
    else
      @centro_de_custo.destroy
      respond_to do |format|
        format.html { redirect_to centros_de_custo_path, notice: 'Centro de custo excluído com sucesso!' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_centro_de_custo
    @centro_de_custo = CentroDeCusto.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Centro de custo não encontrado' }, status: :not_found
  end

  def centro_de_custo_params
    params.require(:centro_de_custo).permit(:nome, :codigo, :ativo, :tipo)
  end
end

