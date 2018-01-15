# frozen_string_literal: true

json.extract! consent_form, :id, :created_at, :updated_at
json.url consent_form_url(consent_form, format: :json)
