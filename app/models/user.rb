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

  def self.search(param, id)
    param.strip!
    param.downcase!

    results = self.first_name_search(param, id) + self.last_name_search(param, id) + self.email_search(param, id)

    results = results.uniq
    return results
  end

  def self.first_name_search(param, id)
    return matches("first_name", param, id)
  end

  def self.last_name_search(param, id)
    return matches("last_name", param, id)
  end

  def self.email_search(param, id)
    return matches("email", param, id)
  end

  def self.matches(field, param, id)
    return User.where("#{field} LIKE ? AND id != ?", "%#{param}%", id)
  end

  def self.get_object(u)
    if u.class.name == "User"
      return u
    else #otherwise its an id
      return User.find(u)
    end
  end

end
