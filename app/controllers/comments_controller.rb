class CommentsController < ApplicationController

  COMMENTABLES = ['record', 'user']

  respond_to :json

  def index
    @comments = commentable.comments.page(params[:page]).desc(:created_at)
    respond_with @comments
  end

  def create
    @comment = commentable.comments.build(params[:comment])
    @comment.user = current_user
    @comment.save

    @comment.body = view_context.markdown(@comment.body)
    render json: @comment
  end

  private

  def commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/ and COMMENTABLES.include?($1)
        return "#{$1.classify}Decorator".constantize.find(value)
      end
    end
    nil
  end
end
