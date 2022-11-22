class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :itineraries, through: :users_itineraries, dependent: :destroy
  has_many :users_itineraries, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :activities, through: :reviews, dependent: :destroy

  has_one_attached :image
end
