# frozen_string_literal: true

class ConsentForm < ApplicationRecord
  belongs_to :user
  has_many :projects, inverse_of: :consent_form
  translates :form_text

  has_attached_file :pdf
  validates_attachment_content_type :pdf,
                                    content_type: ['application/pdf']
  validates_attachment_file_name :pdf, matches: [/\.pdf$/i]

  has_many :consent_logs, inverse_of: :consent_form
  has_many :projects, inverse_of: :consent_form

  scope :active_at, lambda { |date|
                      where(active: true)
                        .where('consent_forms.start_date <= ?', date)
                        .where('consent_forms.end_date IS NULL OR consent_forms.end_date >= ?', date)
                    }

  def global?
    projects.count == 0
  end

  def is_active?
    now = Date.today
    active && start_date <= now && (end_date.nil? || end_date >= now)
  end
end
