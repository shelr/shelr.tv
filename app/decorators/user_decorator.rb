require 'digest/md5'

class UserDecorator < ApplicationDecorator
  decorates :user

  def avatar_url(size)
    return "/assets/avatars/anonymous-#{size}.png" if model.nickname == 'Anonymous'
    if model.email.blank?
      return "/assets/avatars/default-#{size}.png"
    else
      return "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}"
    end
  end
end
