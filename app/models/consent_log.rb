class ConsentLog < ActiveRecord::Base
  belongs_to :consent_form
  belongs_to :user
end
