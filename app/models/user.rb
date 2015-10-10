class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:coinbase]
  
  class << self
    def from_omniauth(auth)
      found_user = self.find_by(email: auth.info.email)

      if found_user.present?
        found_user.update_attributes(
          uid: auth.uid, provider: auth.provider,
          oauth_token: auth.credentials.token,
          oauth_expires_at: Time.at(auth.credentials.expires_at)
        )
        found_user
      else
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
          user.email = auth.info.email
          user.password = Devise.friendly_token[0,20]
          user.first_name = auth.info.first_name
          user.last_name = auth.info.last_name
          user.uid = auth.uid
          user.provider = auth.provider
          user.oauth_token = auth.credentials.token
          user.oauth_expires_at = Time.at(auth.credentials.expires_at)
        end
      end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
          user.email = data["email"] if user.email.blank?
        end
      end
    end
    
  end
  
  def have_offers?
    Contract.where(seller_id: self).select {|c| c.bids.exists?}.exists?
  end
end
