# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  avatar_url             :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, 
         :omniauth_providers => [:facebook]

   has_many :calendars
   has_many :events, :through => :calendars, :source => :events
   has_many :authorizations, :dependent => :destroy


   def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
       data = access_token.info
       user = User.where(:email => data["email"]).first
       

       unless user
           user = User.create(name: data["name"],
                email: data["email"],
                password: Devise.friendly_token[0,20],
                name: data["name"]
               )
       end
       user
   end
   
   def self.find_for_facebook_oauth(auth)
     where(auth.slice(:provider, :uid)).first_or_create do |user|
         user.provider = auth.provider
         user.uid = auth.uid
         user.email = auth.info.email
         user.password = Devise.friendly_token[0,20]
         user.name = auth.info.name
         user.avatar_url = auth.info.image
         user.oauth_token = auth.credentials.token
         user.oauth_expires_at = Time.at(auth.credentials.expires_at)
     end
   end
   
   def self.new_with_session(params, session)
     super.tap do |user|
       if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
         user.email = data["email"] if user.email.blank?
       end
     end
   end
   
   def facebook
     @facebook ||= Koala::Facebook::API.new(oauth_token, ENV["FACEBOOK_SECRET"])
     block_given? ? yield(@facebook) : @facebook
   rescue Koala::Facebook::APIError
     logger.info e.to_s
     nil
   end
   
   def friends_count
     facebook.get_connection("me", "friends").size
   end

   
end
