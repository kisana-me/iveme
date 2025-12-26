class SessionsController < ApplicationController
  before_action :require_signin, except: %i[start]
  before_action :require_signout, only: %i[start]
  before_action :set_session, only: %i[show edit update destroy]

  def start; end

  def signout
    if sign_out
      redirect_to root_path, notice: "サインアウトしました"
    else
      redirect_to root_path, alert: "サインアウトできませんでした"
    end
  end

  # 以下サインイン済み #

  def index
    @sessions = Session.where(account: @current_account, deleted: false)
  end

  def show; end

  def edit; end

  def update
    if @session.update!(session_params)
      redirect_to session_path(@session.token_lookup), notice: "セッションを更新しました"
    else
      flash.now[:alert] = "セッションを更新できませんでした"
      render :edit
    end
  end

  # bad
  def destroy
    @session.update(deleted: true)
    redirect_to sessions_path, notice: "セッションを削除しました"
  end

  private

  def set_session
    @session = Session
      .isnt_deleted
      .find_by(account: @current_account, lookup: params[:id])
  end

  def session_params
    params.expect(session: [ :name ])
  end
end
