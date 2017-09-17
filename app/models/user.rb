class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :rememberable, :validatable # , :trackable, :recoverable
  def email_required?
    false
  end

  def email_changed?
    false
  end
  def will_save_change_to_email?
    false
  end
end
