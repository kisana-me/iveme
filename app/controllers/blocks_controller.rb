class BlocksController < ApplicationController
  before_action :require_signin

  def new
    @block = Block.new
    @page = Page.is_normal.find_by!(aid: params[:page_aid])
    render turbo_stream: turbo_stream.update("new_block", partial: "form", locals: { block: @block, url: blocks_path, page_aid: params[:page_aid] })
  end

  def create
    @page = Page.is_normal.find_by!(aid: params[:page_aid])
    @block = Block.new(block_params)
    @block.page = @page
    if @block.save
      render :create, formats: :turbo_stream
    else
      render :new, status: :unprocessable_entity, formats: :turbo_stream
    end
  end

  def edit
    @block = Block.is_normal.find_by!(aid: params[:aid])
    render turbo_stream: turbo_stream.update("block_#{@block.aid}", partial: "form", locals: { block: @block, url: block_path(@block.aid), page_aid: params[:page_aid] })
  end

  def update
    @block = Block.is_normal.find_by!(aid: params[:aid])
    if @block.update(block_params)
      flash.now[:notice] = "更新しました"
      render turbo_stream: turbo_stream.replace("block_#{@block.aid}", partial: "block", locals: { block: @block })
    else
      render :edit, status: :unprocessable_entity, formats: :turbo_stream
    end
  end

  def destroy
    @block = Block.is_normal.find_by!(aid: params[:aid])
    if @block.update(position: nil, status: :deleted)
      flash.now[:notice] = "削除しました"
      render turbo_stream: turbo_stream.remove("block_#{@block.aid}")
    else
      render :edit, status: :unprocessable_entity, formats: :turbo_stream
    end
  end

  def up
    @block = Block.is_normal.find_by!(aid: params[:aid])
    @block.move_higher

    render_list_update
  end

  def down
    @block = Block.is_normal.find_by!(aid: params[:aid])
    @block.move_lower

    render_list_update
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

  def render_list_update
    @blocks = @block.page.blocks.is_normal.ordered

    render turbo_stream: turbo_stream.update(
      "blocks",
      partial: "blocks/block",
      collection: @blocks,
      as: "block"
    )
  end
end
