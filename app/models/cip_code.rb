class CipCode < ActiveRecord::Base
  has_many :users, :inverse_of => :cip_codes
end
