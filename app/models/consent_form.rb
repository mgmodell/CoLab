# frozen_string_literal: true

class ConsentForm < ActiveRecord::Base
  belongs_to :user
  has_many :projects, inverse_of: :consent_form
  translates :form_text

  has_attached_file :pdf
  validates_attachment_content_type :pdf,
                                    content_type: ['application/pdf']
  validates_attachment_file_name :pdf, matches: [/\.pdf$/i]

  has_many :consent_logs, inverse_of: :consent_form
  has_many :projects, inverse_of: :consent_form

  def global?
    projects.count == 0
  end

  def is_active?
    now = Date.today
    active && now >= start_date && (end_date.nil? || now <= end_date)
  end
end
