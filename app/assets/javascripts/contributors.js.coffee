class Contributor
  roles:
    antono: 'Client and Server development, initial idea :)'
    Gonzih: 'Server developer, bot tamer'

  constructor: (data) ->
    @data = data

  render: =>
    html = Mustache.render(@template, this)
    $('.contributors').append(html)

  github_url: =>
    "https://github.com/#{@data.login}"

  avatar_url: =>
    "http://www.gravatar.com/avatar/#{@data.gravatar_id}?s=100"

  name: =>
    @data.name

  nick: =>
    @data.login

  role: =>
    if @roles[@data.login]
      @roles[@data.login]
    else
      'Contributor!'

  contributions: =>
    @data.contributions

  template:
    '
      <div class="user big">
        <a class="avatar" href="{{github_url}}">
          <img src="{{avatar_url}}" alt="{{name}}">
        </a>

        <div class="desc">
          <strong>Nick</strong>
          <a href="{{github_url}}">{{nick}}</a>
        </div>

        <div class="desc">
          <strong>Role</strong>
          <p>{{role}}</p>
        </div>

        <div class="desc">
          <strong>Contributions</strong>
          <p>{{contributions}}</p>
        </div>

        <div class="desc">
          <strong>Github</strong>
          <a href="{{github_url}}">{{github_url}}</a>
        </div>
      </div>
    '

class Contributors
  constructor: ->
    @users = {}
    @urls = [
      'http://github.com/api/v2/json/repos/show/shelr/shelr.tv/contributors?callback=?',
      'http://github.com/api/v2/json/repos/show/shelr/shelr/contributors?callback=?',
      'http://github.com/api/v2/json/repos/show/shelr/shelr-hubot/contributors?callback=?'
    ]

    @url = 0
    $.getJSON(@urls[@url], @callback)

  callback: (data) =>
    users = data.contributors

    for user in users
      if @users[user.login]
        @users[user.login].contributions += user.contributions
      else
        @users[user.login] = user

    @url += 1
    if @url < @urls.length
      $.getJSON(@urls[@url], @callback)
    else
      @render()

  render: =>
    $('.contributors').html('')
    users = @sorted()

    for login, user of users
      (new Contributor(user)).render()

  sorted: =>
    users = []

    for login, user of @users
      users.push(user)

    users.sort((a,b) ->
      b.contributions - a.contributions
    )


@Contributors = Contributors
