class PagesController < ApplicationController
  before_action :require_signin, only: %i[new create edit update]

  def show
    @page = Page.is_normal.find_by!(name_id: params[:name_id])
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    @page.account = @current_account
    if @page.save
      redirect_to page_path(@page.name_id), notice: "ページを作成しました"
    else
      render :new
    end
  end

  def edit
    @page = Page.is_normal.find_by!(aid: params[:aid])
  end

  def update
    @page = Page.is_normal.find_by!(aid: params[:aid])
    if @page.update(page_params)
      redirect_to page_path(@page.name_id), notice: "ページを更新しました"
    else
      render :edit
    end
  end

  def destroy
    @page = Page.is_normal.find_by!(aid: params[:aid])
    if @page.update(status: :deleted)
      redirect_to root_path, notice: "ページを削除しました"
    else
      redirect_to page_path(@page.name_id), alert: "ページの削除に失敗しました"
    end
  end

  def index
    @document = Document.unscoped.find_by(name_id: "index", status: :specific)
  end

  def terms_of_service
    @document = Document.unscoped.find_by(name_id: "terms_of_service", status: :specific)
  end

  def privacy_policy
    @document = Document.unscoped.find_by(name_id: "privacy_policy", status: :specific)
  end

  def contact
    @document = Document.unscoped.find_by(name_id: "contact", status: :specific)
  end

  def sitemap
    @document = Document.unscoped.find_by(name_id: "sitemap", status: :specific)
  end

  private

  def page_params
    params.expect(
      page: [
        :name_id,
        :title,
        :description,
        :font_family,
        :font_weight,
        :font_color,
        :block_color,
        :accent_color,
        :background_color,
        :gradient_color,
        :page_type,
        :icon_aid,
        :icon_file,
        :background_aid,
        :background_file
      ]
    )
  end
end
