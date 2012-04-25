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

  def markdown(text)
    text ||= ''
    renderer_options = { hard_wrap: true, filter_html: true }
    markdown_options = { fenced_code_blocks: true, autolink: true,  no_intra_emphasis: true, space_after_headers: true }
    @markdown = Redcarpet::Markdown.new(HTMLWithAlbinoRenderer.new(renderer_options), markdown_options)

    @markdown.render(text).html_safe
  end
end
