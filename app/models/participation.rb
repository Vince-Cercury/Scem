class Participation < ActiveRecord::Base
  belongs_to :term
  belongs_to :user
end