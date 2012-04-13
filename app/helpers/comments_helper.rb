module CommentsHelper
  def comment_link(comment, text)
    link_to(text, record_path(comment.commentable, anchor: dom_id(comment)))
  end
end
