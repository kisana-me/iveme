class BlocksController < ApplicationController
  before_action :require_signin

  def new
    @block = Block.new
  end

  def create
    @page = Page.find_by!(aid: params[:page_aid])
    @block = Block.new(block_params)
    @block.page = @page
    if @block.save
      flash.now[:notice] = "追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @block = Block.find_by!(aid: params[:aid])
  end

  def update
    @block = Block.find_by!(aid: params[:aid])
    if @block.update(block_params)
      flash.now[:notice] = "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def block_params
    params.expect(
      block: [
        :title,
        :description
      ]
    )
  end
end
