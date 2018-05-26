require 'digest/md5'

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

  include Gravtastic
  gravtastic

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def self.search(param)
    param.strip!
    param.downcase!

    results = self.first_name_search(param) + self.last_name_search(param) + self.email_search(param)

    results = results.uniq
    return results
  end

  def self.first_name_search(param)
    return matches("first_name", param)
  end

  def self.last_name_search(param)
    return matches("last_name", param)
  end

  def self.email_search(param)
    return matches("email", param)
  end

  def self.matches(field, param)
    return User.where("#{field} LIKE ? AND id != ?", "%#{param}%", 1)
  end

  def self.get_object(u)
    if u.class.name == "User"
      return u
    else
      return JSON.parse(u, object_class: User)
    end
  end

end
