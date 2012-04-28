#= require markitup_settings

jQuery ->
  new Shelr.Views.Comments.Form $('.comment-form form')
  $('#comment_body').markItUp(myMarkdownSettings)
