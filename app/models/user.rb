class User < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name

  has_many :searchterms
  has_many :movies
  has_many :essays, :through => :movies

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable



end
