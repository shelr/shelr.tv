class CommentDecorator < ApplicationDecorator
  decorates :comment
  decorates_association :user
end
