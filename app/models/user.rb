class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  validates :first_name, presence: true, length: {minimum: 1}
  validates :last_name, presence: true, length: {minimum: 1}
  validates :username, presence: true, length: {minimum: 3, maximum: 12}

  has_many :user_habits
  has_many :habits, through: :user_habits

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end
end
