class User < ApplicationRecord
  validates_presence_of :email, :password, :username

  validates_uniqueness_of :email, :username
  validates_size_of :username, within: 3..15
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP
end
