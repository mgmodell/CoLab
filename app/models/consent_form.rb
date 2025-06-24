# frozen_string_literal: true

class ConsentForm < ApplicationRecord
  belongs_to :user
  translates :form_text

  has_one_attached :pdf
  # TODO: Must build out the attachment validators
  # validates_attachment_content_type :pdf,
  #                                  content_type: ['application/pdf']
  # validates_attachment_file_name :pdf, matches: [/\.pdf$/i]

  has_many :consent_logs, inverse_of: :consent_form, dependent: :destroy
  has_many :courses, inverse_of: :consent_form, dependent: :nullify

  scope :active_at, lambda { | date |
                      where( active: true )
                        .where( 'consent_forms.start_date <= ?', date )
                        .where( 'consent_forms.end_date IS NULL OR consent_forms.end_date >= ?', date )
                    }

  scope :global_active_at, lambda { | date |
                             where( active: true, courses_count: 0 )
                               .where( 'consent_forms.start_date <= ?', date )
                               .where( 'consent_forms.end_date IS NULL OR consent_forms.end_date >= ?', date )
                           }

  def global?
    courses.empty?
  end

  def is_active?
    now = Time.zone.today
    active && start_date <= now && ( end_date.nil? || end_date >= now )
  end
end
