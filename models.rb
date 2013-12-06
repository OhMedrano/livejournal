class User < ActiveRecord::Base

  attr_accessor :password

  before_save :encrypt_password

  validates_uniqueness_of :email
  validates_uniqueness_of :username
  validates_presence_of :fname
  validates_presence_of :lname

  def encrypt_password
    if self.password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(email, password)
    user = User.where(email: email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def full_name
    fname + ' ' + lname
  end

  has_many :posts
end

class Post < ActiveRecord::Base

  belongs_to :user
end