class ConsentForm < ActiveRecord::Base
  belongs_to :user
  has_many :projects, inverse_of: :consent_form

  has_attached_file :pdf
  validates_attachment_content_type :pdf,
                                    content_type: ['application/pdf']

  has_many :consent_logs, inverse_of: :consent_form
  has_many :projects, inverse_of: :consent_form

  def global?
    projects.count == 0
  end
end
