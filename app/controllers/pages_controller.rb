class PagesController < ApplicationController
  before_action :require_signin, only: %i[new create edit update]

  def show
    @page = Page.find_by!(name_id: params[:name_id])
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
    @page = Page.find_by!(aid: params[:aid])
  end

  def update
    @page = Page.find_by!(aid: params[:aid])
    if @page.update(page_params)
      redirect_to page_path(@page.name_id), notice: "ページを更新しました"
    else
      render :edit
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
        :color,
        :size
      ]
    )
  end
end
