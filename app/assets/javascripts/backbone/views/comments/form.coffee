class Shelr.Views.Comments.Form extends Backbone.View

  events:
    "click .btn-group .cancel": "clear"

  initialize: (form) ->
    super
    @el = form
    @el.bind 'ajax:success', @displayComment
    @el.bind 'ajax:error', @handleError

  handleError: (e, xhr, status, error) =>
    console.log("error json: " + xhr.responseText)

  displayComment: (e, data, status, xhr) =>
    @el.find('textarea').val("")
    $('iframe.markItUpPreviewFrame').remove()
    tpl = $('.comment-template').clone()
    tpl.removeClass('hidden').removeClass('comment-template')
    tpl.find('.body').html(data.body)
    $('.comments').append tpl

  clear: =>
    @el.reset()
