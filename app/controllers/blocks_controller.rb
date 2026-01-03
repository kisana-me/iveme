class BlocksController < ApplicationController
  before_action :require_signin

  def new
    @block = Block.new
    @page = Page.find_by!(aid: params[:page_aid])
    render turbo_stream: turbo_stream.update("new_block", partial: "form", locals: { block: @block, page_aid: params[:page_aid] })
  end

  def create
    @page = Page.find_by!(aid: params[:page_aid])
    @block = Block.new(block_params)
    @block.page = @page
    if @block.save
      render :create, formats: :turbo_stream
    else
      render :new, status: :unprocessable_entity, formats: :turbo_stream
    end
  end

  def edit
    @block = Block.find_by!(aid: params[:aid])
    # render turbo_stream: turbo_stream.update("block_#{@block.aid}", partial: "form", locals: { block: @block })
  end

  def update
    @block = Block.find_by!(aid: params[:aid])
    if @block.update(block_params)
      flash.now[:notice] = "更新しました"
      # render turbo_stream: turbo_stream.update?replace?("block_#{@block.aid}", partial: "block", locals: { block: @block })
    else
      render :edit, status: :unprocessable_entity, formats: :turbo_stream
    end
  end

  private

  def block_params
    params.expect(
      block: [
        :title,
        :description,
        :url,
        :visibility,
        :status
      ]
    )
  end
end
