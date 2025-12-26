class SettingsController < ApplicationController
  before_action :require_signin
  before_action :set_account, only: %i[ account patch_account ]

  def index
  end

  def account
  end

  def patch_account
    if @account.update(account_params)
      redirect_to settings_account_path, notice: "アカウント情報を更新しました"
    else
      flash.now[:alert] = "アカウント情報を更新できませんでした"
      render :account
    end
  end

  def leave; end

  def delete_leave
    @current_account.update(status: :deleted)
    sign_out
    redirect_to root_url, notice: "ご利用いただきありがとうございました"
  end

  private

  def set_account
    @account = Account.find_by(aid: @current_account.aid)
  end

  def account_params
    params.expect(
      account: [
        :name,
        :name_id,
        :description,
        :birthdate,
        :visibility,
        :icon_file
      ]
    )
  end
end
