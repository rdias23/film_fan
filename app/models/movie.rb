class Movie < ActiveRecord::Base
  belongs_to :user
  has_one :essay, dependent: :destroy

  after_create :create_essay

end
