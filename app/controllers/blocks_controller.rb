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
      flash.now[:notice] = "ブロックを作成しました"
      render :create, formats: :turbo_stream
    else
      flash.now[:alert] = "ブロックを作成できませんでした"
      render turbo_stream: [
        turbo_stream.update(
          "new_block",
          partial: "form",
          locals: { block: @block, url: blocks_path }
        ),
        turbo_stream.update("flash", partial: "shared/flash")
      ], status: :unprocessable_entity
    end
  end

  def edit
    @block = Block.is_normal.find_by!(aid: params[:aid])
    render turbo_stream: turbo_stream.update("block_#{@block.aid}", partial: "form", locals: { block: @block, url: block_path(@block.aid) })
  end

  def update
    @block = Block.is_normal.find_by!(aid: params[:aid])
    if @block.update(block_params)
      flash.now[:notice] = "ブロックを更新しました"
      render turbo_stream: [
        turbo_stream.replace("block_#{@block.aid}", partial: "block", locals: { block: @block, editable: true }),
        turbo_stream.update("flash", partial: "shared/flash")
      ]
    else
      flash.now[:alert] = "ブロックを更新できませんでした"
      render turbo_stream: [
        turbo_stream.update(
          "block_#{@block.aid}",
          partial: "form",
          locals: { block: @block, url: block_path(@block.aid) }
        ),
        turbo_stream.update("flash", partial: "shared/flash")
      ], status: :unprocessable_entity
    end
  end

  def destroy
    @block = Block.is_normal.find_by!(aid: params[:aid])
    if @block.update(position: nil, status: :deleted)
      flash.now[:notice] = "ブロックを削除しました"
      render turbo_stream: [
        turbo_stream.remove("block_#{@block.aid}"),
        turbo_stream.update("flash", partial: "shared/flash")
      ]
    else
      flash.now[:alert] = "ブロックを削除できませんでした"
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :unprocessable_entity
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
      as: "block",
      locals: { editable: true }
    )
  end
end
