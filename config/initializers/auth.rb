require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do

  provider :developer unless Rails.env.production?

  provider :github, Shelr.config['github']['id'], Shelr.config['github']['secret'],
           :client_options => {:ssl => {:ca_path => '/etc/ssl/certs'} }

  provider :twitter, Shelr.config['twitter']['id'], Shelr.config['twitter']['secret']

  provider :google_oauth2, Shelr.config['google']['id'], Shelr.config['google']['secret'], {
    :access_type => 'online',
    :approval_prompt => ''
  }

  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
end
