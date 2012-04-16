class HomeController < ApplicationController
  respond_to :html, :xml

  def landing
    if logged_in? && current_user.comments_for_records.any?
      redirect_to dashboard_path
    else
      @records = RecordDecorator.decorate(Record.visible_by(current_user).desc(:created_at).page(1))
    end
  end

  def opensearch
    response.headers["Content-Type"] = 'application/opensearchdescription+xml'
    render :layout => false
  end

  def dashboard
    if logged_in?
      @comments = CommentDecorator.decorate(current_user.comments_for_records(params[:page]))
    else
      redirect_to records_path
    end
  end
end
