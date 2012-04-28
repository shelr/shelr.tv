module ApplicationHelper
  def player_for(record, options = {})
    render 'shared/player', record: record, embed: options[:embed]
  end

  def controller_and_action_class_names
    [controller_name, '-controller', ' ', action_name, '-action'].join
  end

  def active_if(regex)
    'active' if request.env['PATH_INFO'] =~ regex
  end

  def comment_url(comment)
    comment = comment.model if comment.is_a?(CommentDecorator)
    record_url(comment.commentable, anchor: dom_id(comment))
  end
end
