class PagesController < ApplicationController
  before_action :require_signin, only: %i[ home new create edit update destroy ]

  def new
    @page = Page.new
    @page.account = @current_account
    if @current_account.page_limit_exceeded?
      return redirect_to home_path, alert: I18n.t(
        "activerecord.errors.messages.page_limit_exceeded",
        limit: @current_account.page_limit
      )
    end
    @is_first_page = @current_account.pages.is_normal.count.zero?
  end

  def create
    @page = Page.new(page_params)
    @page.account = @current_account
    if @current_account.pages.is_normal.count.zero?
      @page.name_id = "index"
    end

    if @page.save
      redirect_to account_page_path(@current_account.name_id, @page.name_id), notice: "ページを作成しました"
    else
      render :new
    end
  end

  def edit
    @page = Page.is_normal.find_by!(aid: params[:aid])
  end

  def update
    @page = Page.is_normal.find_by!(aid: params[:aid])

    pp = page_params
    remove_icon = pp[:remove_icon].to_s == "1"
    remove_background = pp[:remove_background].to_s == "1"

    if remove_icon && pp[:icon_file].blank? && pp[:icon_aid].blank?
      @page.icon = nil
    end

    if remove_background && pp[:background_file].blank? && pp[:background_aid].blank?
      @page.background = nil
    end

    if @page.update(pp.except(:remove_icon, :remove_background))
      redirect_to edit_page_path(@page.aid), notice: "ページを更新しました"
    else
      render :edit
    end
  end

  def destroy
    @page = Page.is_normal.find_by!(aid: params[:aid])
    if @page.name_id == "index"
      return redirect_to account_page_path(@current_account.name_id, @page.name_id), alert: "トップページは削除できません"
    end

    if @page.update(status: :deleted)
      redirect_to home_path, notice: "ページを削除しました"
    else
      redirect_to account_page_path(@current_account.name_id, @page.name_id), alert: "ページの削除に失敗しました"
    end
  end

  def home
    @pages = @current_account.pages.is_normal
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
        :remove_icon,
        :background_aid,
        :background_file,
        :remove_background
      ]
    )
  end
end
