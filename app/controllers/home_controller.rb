class HomeController < ApplicationController
  respond_to :html, :xml

  def landing
    if logged_in? && current_user.comments_for_records.any?
      redirect_to dashboard_path
    else
      @records = Record.desc(:created_at).page(1)
    end
  end

  def about
  end

  def opensearch
    response.headers["Content-Type"] = 'application/opensearchdescription+xml'
    render :layout => false
  end

  def dashboard
    if logged_in?
      @comments = current_user.comments_for_records(params[:page])
    else
      redirect_to records_path
    end
  end
end
