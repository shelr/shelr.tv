class HomeController < ApplicationController
  respond_to :html, :xml, :atom

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
    # format atom
    if request.format == 'atom'
      # key present => find user by key
      if params[:key].present?
        @user = User.where(atom_key: params[:key]).first

        # user with given key found => render atom bulilder
        if @user.present?
          @comments = CommentDecorator.decorate(@user.comments_for_records.reverse)
        # user with given key not found => render blank body
        else
          render text: ''
        end
      # no key => render blank body
      else
        render text: ''
      end
    # format html
    else
      # user logged in => render fetch comments, render dashboard
      if logged_in?
        page      = params[:page] || 1
        comments  = current_user.comments_for_records
        comments  = Kaminari.paginate_array(comments).page(page).per(20)
        @comments = CommentDecorator.decorate(comments)
      # user not logged in => redirect to records
      else
        redirect_to records_path
      end
    end
  end
end
