class DocumentsController < ApplicationController
  before_action :require_admin, except: [ :index, :show ]
  before_action :set_correct_document, only: %i[ edit update destroy ]

  def index
    if admin?
      documents = Document.all
    else
      documents = Document.is_normal.is_opened
    end
    @documents = set_pagination_for(documents)
  end

  def show
    @document = Document.is_normal.is_opened.find_by(name_id: params.expect(:name_id))

    render_404 unless @document
  end

  def new
    @document = Document.new
  end

  def edit; end

  def create
    @document = Document.new(document_params)
    if @document.save
      redirect_to documents_path, notice: "文書を作成しました"
    else
      flash.now[:alert] = "文書を作成できませんでした"
      render :new
    end
  end

  def update
    if @document.update(document_params)
      redirect_to document_path(@document.name_id), notice: "文書を更新しました"
    else
      flash.now[:alert] = "文書を更新できませんでした"
      render :edit
    end
  end

  def destroy
    if @document.update(status: :deleted)
      redirect_to documents_path, notice: "文書を削除しました"
    else
      flash.now[:alert] = "文書を削除できませんでした"
      render :edit
    end
  end

  private

  def document_params
    params.expect(
      document: [
        :name_id,
        :title,
        :summary,
        :content,
        :published_at,
        :edited_at,
        :visibility
      ]
    )
  end

  def set_correct_document
    @document = Document.find_by(aid: params[:aid])
    render_404 unless @document
  end
end
