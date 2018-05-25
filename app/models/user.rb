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

  def self.search(param)
    param.strip!
    param.downcase!
    
  end

  def self.first_name_search(param)
  end

  def self.last_name_search(param)
  end

  def self.email_search(param)
  end

  def matches(field, id)
    return User.where("#{field} LIKE ? AND id != ?", "%#{param}%", id)
  end

end
