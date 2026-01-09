class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show page ]

  def index
    accounts = Account
      .is_normal
      .is_opened
      .includes(:icon)

    @accounts = set_pagination_for(accounts)
  end

  def show
    @page = @account.pages.is_normal.find_by!(name_id: "index")
  end

  def page
    if params[:page_name_id] == "index"
      return redirect_to account_path(@account.name_id)
    end

    @page = @account.pages.is_normal.find_by!(name_id: params[:page_name_id])
    render :show
  end

  private

  def set_account
    return if (@account = Account.is_normal.isnt_closed.find_by(name_id: params[:name_id]))
    return if admin? && (@account = Account.unscoped.find_by(name_id: params[:name_id]))

    render_404
  end
end
