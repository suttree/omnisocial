module Omnisocial
  class LoginAccount < ActiveRecord::Base
    belongs_to :user, :class_name => '::User'
    serialize :user_hash
    default_scope :include => :user

    before_save do
      self.login = self.remote_account_id if self.login.blank?
    end
  
    def self.find_or_create_from_auth_hash(auth_hash)
      if (account = find_by_remote_account_id(auth_hash['uid']))
        account.assign_account_info(auth_hash)
        account.save
        account
      else
        create_from_auth_hash(auth_hash)
      end
    end
  
    def self.create_from_auth_hash(auth_hash)
      create do |account|
        account.assign_account_info(auth_hash)
      end
    end
  
    def find_or_create_user
      return self.user if self.user
    
      ::User.create do |user|
        user.login_accounts << self
      end
    end
  end
end
