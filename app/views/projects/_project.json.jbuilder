# frozen_string_literal: true
json.extract! project, :id, :user_id, :name, :ends_at, :created_at, :updated_at
json.url project_url(project, format: :json)
