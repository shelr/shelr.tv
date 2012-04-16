class RecordDecorator < ApplicationDecorator
  decorates :record
  decorates_association :user
  decorates_association :comments
end
