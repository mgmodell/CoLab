class ConsentLog < ActiveRecord::Base
  belongs_to :consent_form, inverse_of: :consent_logs
  belongs_to :user, inverse_of: :consent_logs
end
