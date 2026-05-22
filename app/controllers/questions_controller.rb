class QuestionsController < ApplicationController
  before_action :require_signin
  before_action :set_page
  before_action :require_page_owner, except: [ :create ]

  def index
    @questions = Question.is_normal.where(page: @page).order(created_at: :desc)
    @mpage = @page
    @questions = set_pagination_for(@questions)
  end

  def create
    @question = Question.new(question_params)
    @question.page = @page

    # Turnstile
    unless verify_turnstile(params["cf-turnstile-response"])
      @question.errors.add(:base, :failed_captcha)
      flash.now[:alert] = "質問を作成できませんでした"
      return render turbo_stream: [
        turbo_stream.update(
          "question_form",
          partial: "form",
          locals: { question: @question, url: page_questions_path(@page.aid) }
        ),
        turbo_stream.update("flash", partial: "shared/flash")
      ], status: :unprocessable_entity
    end

    if @question.save
      flash.now[:notice] = "質問を作成しました"
      render :create, formats: :turbo_stream
    else
      flash.now[:alert] = "質問を作成できませんでした"
      render turbo_stream: [
        turbo_stream.update(
          "question_form",
          partial: "form",
          locals: { question: @question, url: page_questions_path(@page.aid) }
        ),
        turbo_stream.update("flash", partial: "shared/flash")
      ], status: :unprocessable_entity
    end
  end

  def update
    @question = Question.is_normal.find_by!(aid: params[:aid])
    if @question.update(update_question_params)
      flash.now[:notice] = "質問を更新しました"
      render turbo_stream: [
        turbo_stream.replace("question_#{@question.aid}", partial: "question", locals: { question: @question }),
        turbo_stream.update("flash", partial: "shared/flash")
      ]
    else
      flash.now[:alert] = "質問を更新できませんでした"
      render turbo_stream: [
        turbo_stream.update(
          "question_#{@question.aid}",
          partial: "form",
          locals: { question: @question, url: page_question_path(params[:page_aid], @question.aid) }
        ),
        turbo_stream.update("flash", partial: "shared/flash")
      ], status: :unprocessable_entity
    end
  end

  def destroy
    @question = Question.is_normal.find_by!(aid: params[:aid])
    if @question.update(status: :deleted)
      flash.now[:notice] = "質問を削除しました"
      render turbo_stream: [
        turbo_stream.remove("question_#{@question.aid}"),
        turbo_stream.update("flash", partial: "shared/flash")
      ]
    else
      flash.now[:alert] = "質問を削除できませんでした"
      render turbo_stream: turbo_stream.update("flash", partial: "shared/flash"), status: :unprocessable_entity
    end
  end

  private

  def set_page
    @page = Page.is_normal.find_by!(aid: params[:page_aid])
  end

  def require_page_owner
    # unless @page.account == current_account
    #   return render_404
    # end
  end

  def question_params
    params.expect(
      question: [
        :content
      ]
    )
  end

  def update_question_params
    params.expect(
      question: [
        :answer,
        :read,
        :visibility
      ]
    )
  end
end
