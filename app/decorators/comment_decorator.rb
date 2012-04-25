class CommentDecorator < ApplicationDecorator
  decorates :comment
  decorates_association :user

  def body_link
    h.link_to(body, record_path)
  end

  def body
    h.markdown(model.body)
  end

  def updated_at
    h.link_to(h.l(model.updated_at, format: :short), record_path)
  end

  def nickname
    h.link_to(commentator.nickname, commentator)
  end

  def avatar
    h.image_tag(commentator.avatar_url(50))
  end

  private

  def record_path
    h.record_path(model.commentable, anchor: h.dom_id(model))
  end

  def commentator
    user = self.user || h.current_user
  end
end
