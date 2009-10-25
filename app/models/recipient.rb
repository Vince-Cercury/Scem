class Recipient < ActiveRecord::Base
  belongs_to :mail
  belongs_to :user
end